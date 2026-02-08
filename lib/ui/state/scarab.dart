import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scarab/events/bus.dart';
import 'package:scarab/events/event.dart';
import 'package:scarab/models/app.dart';
import 'package:scarab/models/device.dart';
import 'package:scarab/models/chat_message.dart';
import 'package:scarab/services/launcher.dart';
import 'package:scarab/models/session.dart';
import 'package:scarab/ui/state/tools/repository.dart';
import '../../utils/consts.dart';
part 'scarab.g.dart';

@riverpod
class Scarab extends _$Scarab {
  late ChatSession _session;
  late GenerativeModel _model;
  StreamSubscription<AppEvent>? _eventSubscription;
  final ToolRepository _toolRepository = ToolRepository();

  @override
  AppState build() {
    _initializeModel();

    _eventSubscription?.cancel();
    _eventSubscription = AppEventBus.initHub().listen(_handleEvent);

    // Clean up when the provider is disposed
    ref.onDispose(() => _eventSubscription?.cancel());

    return AppState();
  }

  void _initializeModel() {
    var tools = _toolRepository.tools
        .map((tool) => tool.toGeminiTool())
        .toList();

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
      systemInstruction: Content.system(scarabSystemInstruction),
      tools: tools,
    );

    // Start a session with empty history
    _session = _model.startChat();
  }

  void _handleEvent(AppEvent event) {
    // 2. Map external events to AI state/history
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

  Future<void> sendPrompt(String text) async {
    final userContent = Content.text(text);

    state = state.copyWith(
      isThinking: true,
      history: [...state.history, userContent],
    );

    try {
      var response = await _session.sendMessage(userContent);
      await _toolRepository.processGeminiToolCall(response, _session);

      state = state.copyWith(
        history: _session.history.toList(),
        isThinking: false,
      );
    } catch (e) {
      print("Error during AI response: $e");

      state = state.copyWith(
        isThinking: false,
        history: [...state.history, Content.text("Error: ${e.toString()}")],
      );
    }
  }

  // Helper to clear chat
  void resetChat() {
    _session = _model.startChat();
    state = AppState();
  }
}

@riverpod
List<ChatMessage> chatMessages(Ref ref) {
  // Watch the AI state. Whenever history updates, this provider re-runs.
  final state = ref.watch(scarabProvider);

  return state.history
      .map((content) {
        // 1. Combine all text parts (Gemini responses can have multiple parts)
        final text = content.parts
            .whereType<TextPart>()
            .map((part) => part.text)
            .join('\n');

        // 2. Determine author and user status
        final isUser = content.role == 'user';

        return ChatMessage(
          author: isUser ? "You" : "Scarab",
          text: text.isEmpty
              ? "..."
              : text, // Handle empty parts (like during tool calls)
          isUser: isUser,
        );
      })
      .where((msg) => msg.text != "...")
      .toList(); // Optionally filter out internal noise
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

final deviceAppsProvider = FutureProvider<Map<String, DeviceApplication>>((
  ref,
) async {
  final appsList = await LauncherService.getDeviceApps();
  return {for (var app in appsList) app.packageId: app};
});
