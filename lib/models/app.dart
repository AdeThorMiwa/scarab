import 'package:firebase_ai/firebase_ai.dart';
import 'package:scarab/models/session.dart';
import 'package:scarab/services/calendar/event.dart';

class AppState {
  final List<Content> history;
  final bool isThinking;
  final List<CalendarEvent> upcomingEvents;
  Session? activeSession;

  AppState({
    this.history = const [],
    this.isThinking = false,
    this.upcomingEvents = const [],
    this.activeSession,
  });

  AppState copyWith({
    List<Content>? history,
    bool? isThinking,
    List<CalendarEvent>? upcomingEvents,
    Session? activeSession,
  }) {
    return AppState(
      history: history ?? this.history,
      isThinking: isThinking ?? this.isThinking,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      activeSession: activeSession,
    );
  }
}
