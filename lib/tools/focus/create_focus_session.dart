import 'package:firebase_ai/firebase_ai.dart' as fbz;
import 'package:scarab/models/calendar.dart';
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/utils/consts.dart';

class CreateFocusSessionTool extends Tool {
  CreateFocusSessionTool()
    : super(
        'create_focus_session',
        'Call this whenever you want to create a focus session. This will block distracting apps',
        {
          'title': fbz.Schema.string(
            description: 'The title of the focus session',
          ),
          'description': fbz.Schema.string(
            description: 'The description of the focus session',
          ),
          'startTime': fbz.Schema.string(
            description:
                'The start time of the focus session in ISO 8601 format',
          ),
          'endTime': fbz.Schema.string(
            description: 'The end time of the focus session in ISO 8601 format',
          ),
          'allowedApps': fbz.Schema.array(
            items: fbz.Schema.string(
              description: 'The Android package name to allow',
            ),
            description: 'List of allowed app package names',
          ),
        },
      );

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> args) async {
    final req = AddEventToCalendarRequest(
      title: args["title"].toString(),
      description: args["description"].toString(),
      startTime: DateTime.parse(args["startTime"].toString()),
      endTime: DateTime.parse(args["endTime"].toString()),
      allowedApps: List<String>.from(
        (args["allowedApps"] as List<dynamic>?) ?? [],
      ),
      isFocusSession: true,
    );

    print("Creating event with request: $req");

    var event = await CalendarService.addEventToCalendar(
      req,
      calendarId: calendarId,
    );

    return event.toMap();
  }
}
