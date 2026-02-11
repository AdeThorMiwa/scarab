import 'package:firebase_ai/firebase_ai.dart' as fbz;
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/utils/consts.dart';

class GetCalendarEventsTool extends Tool {
  GetCalendarEventsTool()
    : super(
        'get_calendar_events',
        'Get calendar events within a date range. Use to see today\'s schedule or fetch historical data for trend analysis.',
        {
          'startDate': fbz.Schema.string(
            description: 'The start of the date range in ISO 8601 format',
          ),
          'endDate': fbz.Schema.string(
            description: 'The end of the date range in ISO 8601 format',
          ),
          'maxResults': fbz.Schema.integer(
            description: 'Maximum number of events to return. Defaults to 20.',
            nullable: true,
          ),
        },
      );

  @override
  Future<List<Map<String, dynamic>>> execute(Map<String, dynamic> args) async {
    final from = DateTime.parse(args['startDate'].toString());
    final to = DateTime.parse(args['endDate'].toString());
    final maxResults = (args['maxResults'] as num?)?.toInt() ?? 20;

    var events = await CalendarService.getEventsInRange(
      from: from,
      to: to,
      size: maxResults,
      calendarId: calendarId,
    );

    return events.map((e) => e.toMap()).toList();
  }
}
