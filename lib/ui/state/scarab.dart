import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scarab/events/bus.dart';
import 'package:scarab/events/event.dart';
import 'package:scarab/models/app.dart';
import 'package:scarab/models/device.dart';
import 'package:scarab/models/chat_message.dart';
import 'package:scarab/models/execution_log.dart';
import 'package:scarab/services/launcher.dart';
import 'package:scarab/models/session.dart';
import 'package:scarab/skills/registry.dart';
import 'package:scarab/rp_react/llm/provider.dart';
import 'package:scarab/rp_react/llm/gemini_provider.dart';
import 'package:scarab/rp_react/rpa/planner.dart';
import 'package:scarab/rp_react/pea/executor.dart';
import 'package:scarab/rp_react/models.dart';
part 'scarab.g.dart';

@riverpod
class Scarab extends _$Scarab {
  StreamSubscription<AppEvent>? _eventSubscription;
  final SkillRegistry _skillRegistry = SkillRegistry();
  late final ReasonerPlanner _planner;
  late final ProxyExecutor _executor;

  @override
  AppState build() {
    _initialize();

    _eventSubscription?.cancel();
    _eventSubscription = AppEventBus.initHub().listen(_handleEvent);

    // Clean up when the provider is disposed
    ref.onDispose(() => _eventSubscription?.cancel());

    return AppState();
  }

  void _initialize() {
    final llm = GeminiProvider(model: 'gemini-2.5-flash');

    _planner = ReasonerPlanner(llm: llm, skillRegistry: _skillRegistry);

    _executor = ProxyExecutor(llm: llm);
  }

  void _handleEvent(AppEvent event) {
    switch (event) {
      case UpcomingEventsSyncEvent(:final events):
        state = state.copyWith(upcomingEvents: events);
        break;
      case SessionStartedEvent(:final session):
        state = state.copyWith(activeSession: session);
        break;
      case SessionEndedEvent(:final session):
        state = state.copyWith(
          activeSession: null,
          upcomingEvents: state.upcomingEvents
              .where((e) => e.id != session.id)
              .toList(),
        );
        break;
    }
  }

  void _setStatus(String status) {
    state = state.copyWith(currentStatus: status);
  }

  void _clearStatus() {
    state = state.copyWith(clearStatus: true);
  }

  void _log(
    ExecutionLogType type,
    String message, {
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) {
    state = state.copyWith(
      executionLog: [
        ...state.executionLog,
        ExecutionLogEntry(
          timestamp: DateTime.now(),
          type: type,
          message: message,
          duration: duration,
          metadata: metadata,
        ),
      ],
    );
  }

  String _deriveStatus(String instruction, int index, int total) {
    final lower = instruction.toLowerCase();
    if (lower.contains('date') || lower.contains('time')) {
      return 'Checking current date and time...';
    }
    if (lower.contains('calendar') || lower.contains('event')) {
      return 'Checking calendar events...';
    }
    if (lower.contains('focus') || lower.contains('session')) {
      return 'Creating focus session...';
    }
    if (lower.contains('app')) {
      return 'Getting device apps...';
    }
    return 'Executing step ${index + 1} of $total...';
  }

  Future<void> sendPrompt(String text) async {
    final totalStopwatch = Stopwatch()..start();

    state = state.copyWith(
      isThinking: true,
      executionLog: [],
      history: [...state.history, LLMMessage.user(text)],
    );

    try {
      // Planning phase
      _setStatus('Planning...');
      _log(ExecutionLogType.plannerStart, 'Processing user request');

      final plannerStopwatch = Stopwatch()..start();
      var response = await _planner.process(text);
      plannerStopwatch.stop();

      _log(
        ExecutionLogType.plannerResult,
        response.isDirectResponse
            ? 'Direct response'
            : 'Plan: ${response.subSteps?.length ?? 0} steps (skill: ${response.skillId ?? 'none'})',
        duration: plannerStopwatch.elapsed,
      );

      // Handle the planner's response
      while (true) {
        if (response.isDirectResponse) {
          _clearStatus();
          totalStopwatch.stop();
          _log(
            ExecutionLogType.complete,
            'Done',
            duration: totalStopwatch.elapsed,
          );

          state = state.copyWith(
            history: [
              ...state.history,
              LLMMessage.assistant(response.directResponse!),
            ],
            isThinking: false,
          );
          return;
        }

        if (response.isPlan) {
          final skill = response.skillId != null
              ? _skillRegistry.getSkillById(response.skillId!)
              : null;

          final tools = skill?.tools ?? [];
          final contextPrompt = skill?.contextPrompt ?? '';
          final steps = response.subSteps!;

          // Collect all step results to feed back to planner
          final resultParts = <String>[];

          for (var i = 0; i < steps.length; i++) {
            final step = steps[i];

            // Status + log for this step
            _setStatus(_deriveStatus(step.instruction, i, steps.length));
            _log(
              ExecutionLogType.stepStart,
              'Step ${i + 1}: ${step.instruction}',
            );

            final stepSkill = step.skillId != null
                ? _skillRegistry.getSkillById(step.skillId!)
                : skill;
            final stepTools = stepSkill?.tools ?? tools;
            final stepContext = stepSkill?.contextPrompt ?? contextPrompt;

            final stepStopwatch = Stopwatch()..start();
            final result = await _executor.execute(
              instruction: step.instruction,
              tools: stepTools,
              contextPrompt: stepContext,
            );
            stepStopwatch.stop();

            _log(
              ExecutionLogType.stepComplete,
              result.success
                  ? 'Step ${i + 1} completed'
                  : 'Step ${i + 1} failed: ${result.output}',
              duration: stepStopwatch.elapsed,
            );

            resultParts.add(
              'Step ${i + 1} (${step.instruction}): ${result.output}',
            );
          }

          // Feed ALL results back to planner so it can reason about the data
          _setStatus('Reasoning about results...');
          _log(
            ExecutionLogType.plannerStart,
            'Feeding results back to planner',
          );

          final combinedResult = ExecutionResult(
            output: resultParts.join('\n'),
            success: true,
          );

          final reasonStopwatch = Stopwatch()..start();
          response = await _planner.handleResult(combinedResult);
          reasonStopwatch.stop();

          _log(
            ExecutionLogType.plannerResult,
            response.isDirectResponse
                ? 'Final response ready'
                : 'More steps: ${response.subSteps?.length ?? 0}',
            duration: reasonStopwatch.elapsed,
          );
          continue;
        }

        // Fallback
        _clearStatus();
        totalStopwatch.stop();
        _log(
          ExecutionLogType.complete,
          'Done',
          duration: totalStopwatch.elapsed,
        );
        state = state.copyWith(isThinking: false);
        return;
      }
    } catch (e) {
      _clearStatus();
      totalStopwatch.stop();
      _log(
        ExecutionLogType.error,
        e.toString(),
        duration: totalStopwatch.elapsed,
      );

      state = state.copyWith(
        isThinking: false,
        history: [
          ...state.history,
          LLMMessage.assistant("Error: ${e.toString()}"),
        ],
      );
    }
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  void resetChat() {
    _planner.reset();
    state = AppState();
  }
}

@riverpod
List<ChatMessage> chatMessages(Ref ref) {
  final state = ref.watch(scarabProvider);

  return state.history
      .where((msg) => msg.role != LLMRole.tool)
      .map((msg) {
        final isUser = msg.role == LLMRole.user;
        return ChatMessage(
          author: isUser ? 'You' : 'Scarab',
          text: msg.content,
          isUser: isUser,
        );
      })
      .where((msg) => msg.text.isNotEmpty)
      .toList();
}

@riverpod
List<Session> upcomingSessions(Ref ref) {
  final state = ref.watch(scarabProvider);
  print(
    "Upcoming events in state: ${state.upcomingEvents.map((e) => e.title).toList()}",
  );
  return state.upcomingEvents.map((e) => Session.fromCalendarEvent(e)).toList();
}

final activeSessionProvider = FutureProvider<Session?>((ref) async {
  final state = ref.watch(scarabProvider);
  return state.activeSession;
});

@riverpod
List<ExecutionLogEntry> executionLog(Ref ref) {
  return ref.watch(scarabProvider.select((s) => s.executionLog));
}

final deviceAppsProvider = FutureProvider<Map<String, DeviceApplication>>((
  ref,
) async {
  final appsList = await LauncherService.getDeviceApps();
  return {for (var app in appsList) app.packageId: app};
});
