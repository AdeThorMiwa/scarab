import 'package:firebase_ai/firebase_ai.dart' as fbz;
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/utils/consts.dart';

class CreateCalendarEventTool extends Tool {
  CreateCalendarEventTool()
    : super(
        'create_calendar_event',
        'Create a general calendar event (task, appointment, reminder). Use this to schedule tasks on the user\'s calendar.',
        {
          'title': fbz.Schema.string(description: 'The title of the event'),
          'description': fbz.Schema.string(
            description: 'A description of the event',
          ),
          'startTime': fbz.Schema.string(
            description: 'The start time in ISO 8601 format',
          ),
          'endTime': fbz.Schema.string(
            description: 'The end time in ISO 8601 format',
          ),
          'isFreeTime': fbz.Schema.boolean(
            description:
                'Whether this is a flexible/free time block. Defaults to false.',
            nullable: true,
          ),
        },
      );

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> args) async {
    final isFreeTime = args['isFreeTime'] as bool? ?? false;

    var event = await CalendarService.addGeneralEvent(
      title: args['title'].toString(),
      description: args['description'].toString(),
      startTime: DateTime.parse(args['startTime'].toString()),
      endTime: DateTime.parse(args['endTime'].toString()),
      isFreeTime: isFreeTime,
      calendarId: calendarId,
    );

    return event.toMap();
  }
}
