import 'package:scarab/models/execution_log.dart';
import 'package:scarab/models/session.dart';
import 'package:scarab/rp_react/llm/provider.dart';
import 'package:scarab/services/calendar/event.dart';

class AppState {
  final List<LLMMessage> history;
  final bool isThinking;
  final List<CalendarEvent> upcomingEvents;
  final String? currentStatus;
  final List<ExecutionLogEntry> executionLog;
  Session? activeSession;

  AppState({
    this.history = const [],
    this.isThinking = false,
    this.upcomingEvents = const [],
    this.currentStatus,
    this.executionLog = const [],
    this.activeSession,
  });

  AppState copyWith({
    List<LLMMessage>? history,
    bool? isThinking,
    List<CalendarEvent>? upcomingEvents,
    bool clearStatus = false,
    String? currentStatus,
    List<ExecutionLogEntry>? executionLog,
    Session? activeSession,
  }) {
    return AppState(
      history: history ?? this.history,
      isThinking: isThinking ?? this.isThinking,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      currentStatus: clearStatus ? null : (currentStatus ?? this.currentStatus),
      executionLog: executionLog ?? this.executionLog,
      activeSession: activeSession,
    );
  }
}
