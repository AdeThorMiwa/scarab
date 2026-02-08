import 'package:firebase_ai/firebase_ai.dart';
import 'package:scarab/services/calendar/event.dart';

class AppState {
  final List<Content> history;
  final bool isThinking;
  final List<CalendarEvent> upcomingEvents;

  AppState({
    this.history = const [],
    this.isThinking = false,
    this.upcomingEvents = const [],
  });

  AppState copyWith({
    List<Content>? history,
    bool? isThinking,
    List<CalendarEvent>? upcomingEvents,
  }) {
    return AppState(
      history: history ?? this.history,
      isThinking: isThinking ?? this.isThinking,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }
}
