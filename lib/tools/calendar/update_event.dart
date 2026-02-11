import 'package:firebase_ai/firebase_ai.dart' as fbz;
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/services/calendar/event.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/utils/consts.dart';

class UpdateCalendarEventTool extends Tool {
  UpdateCalendarEventTool()
    : super(
        'update_calendar_event',
        'Update an existing calendar event\'s time, title, or description.',
        {
          'eventId': fbz.Schema.string(
            description: 'The ID of the event to update',
          ),
          'title': fbz.Schema.string(
            description: 'New title for the event',
            nullable: true,
          ),
          'description': fbz.Schema.string(
            description: 'New description for the event',
            nullable: true,
          ),
          'startTime': fbz.Schema.string(
            description: 'New start time in ISO 8601 format',
            nullable: true,
          ),
          'endTime': fbz.Schema.string(
            description: 'New end time in ISO 8601 format',
            nullable: true,
          ),
        },
      );

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> args) async {
    final eventId = args['eventId'].toString();

    // Fetch current event to apply partial updates
    var events = await CalendarService.getEventsInRange(
      from: DateTime.now().subtract(Duration(days: 30)),
      to: DateTime.now().add(Duration(days: 30)),
      size: 100,
      calendarId: calendarId,
    );

    var existing = events.where((e) => e.id == eventId).firstOrNull;
    if (existing == null) {
      throw Exception('Event not found: $eventId');
    }

    final updated = CalendarEvent(
      eventId,
      title: args['title']?.toString() ?? existing.title,
      description: args['description']?.toString() ?? existing.description,
      startTime: args['startTime'] != null
          ? DateTime.parse(args['startTime'].toString())
          : existing.startTime,
      endTime: args['endTime'] != null
          ? DateTime.parse(args['endTime'].toString())
          : existing.endTime,
      allowedApps: existing.allowedApps,
      isFreeTime: existing.isFreeTime,
    );

    await CalendarService.updateEvent(updated, calendarId: calendarId);
    return updated.toMap();
  }
}
