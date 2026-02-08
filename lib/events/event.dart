import 'package:scarab/models/session.dart';
import 'package:scarab/services/calendar/event.dart';

sealed class AppEvent {
  const AppEvent();

  Map<String, dynamic> toJson();

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final data = json['data'] as Map<String, dynamic>;

    return switch (type) {
      'upcoming_events_sync' => UpcomingEventsSyncEvent.fromData(data),
      'session_started' => SessionStartedEvent.fromData(data),
      'session_ended' => SessionEndedEvent.fromData(data),
      _ => throw Exception('Unknown event type: $type'),
    };
  }
}

class UpcomingEventsSyncEvent extends AppEvent {
  final List<CalendarEvent> events;
  UpcomingEventsSyncEvent(this.events);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'upcoming_events_sync',
    'data': {'events': events.map((e) => e.toMap()).toList()},
  };

  factory UpcomingEventsSyncEvent.fromData(Map<String, dynamic> data) =>
      UpcomingEventsSyncEvent(
        (data['events'] as List<dynamic>)
            .map((e) => CalendarEvent.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}

class SessionStartedEvent extends AppEvent {
  final Session session;
  SessionStartedEvent(this.session);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'session_started',
    'data': {'session': session.toMap()},
  };

  factory SessionStartedEvent.fromData(Map<String, dynamic> data) =>
      SessionStartedEvent(Session.fromMap(data['session']));
}

class SessionEndedEvent extends AppEvent {
  final Session session;
  SessionEndedEvent(this.session);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'session_ended',
    'data': {'session': session.toMap()},
  };

  factory SessionEndedEvent.fromData(Map<String, dynamic> data) =>
      SessionEndedEvent(Session.fromMap(data['session']));
}
