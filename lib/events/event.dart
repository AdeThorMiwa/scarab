import 'package:scarab/services/calendar/event.dart';

sealed class AppEvent {
  const AppEvent();

  Map<String, dynamic> toJson();

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final data = json['data'] as Map<String, dynamic>;

    return switch (type) {
      'upcoming_events_sync' => UpcomingEventsSyncEvent.fromData(data),
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
