import 'package:firebase_ai/firebase_ai.dart' as fbz;
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/utils/consts.dart';

class DeleteCalendarEventTool extends Tool {
  DeleteCalendarEventTool()
    : super('delete_calendar_event', 'Delete a calendar event by its ID.', {
        'eventId': fbz.Schema.string(
          description: 'The ID of the event to delete',
        ),
      });

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> args) async {
    final eventId = args['eventId'].toString();

    await CalendarService.deleteEvent(eventId, calendarId: calendarId);

    return {'deleted': true, 'eventId': eventId};
  }
}
