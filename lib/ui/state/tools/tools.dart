import 'package:firebase_ai/firebase_ai.dart' as fbz;
import 'package:scarab/models/calendar.dart';
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/services/launcher.dart';
import 'package:scarab/utils/consts.dart';
import 'interface.dart';

class CreateFocusSessionTool extends Tool {
  CreateFocusSessionTool()
    : super(
        'createFocusSession',
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
      isFreeTime: args["isFreeTime"] as bool? ?? false,
    );

    print("Creating event with request: $req");

    var event = await CalendarService.addEventToCalendar(
      req,
      calendarId: calendarId,
    );

    return event.toMap();
  }
}

class GetDeviceAppsTool extends Tool {
  GetDeviceAppsTool()
    : super(
        'getDeviceApps',
        'Call this to get a list of all apps on the device',
        {},
      );

  @override
  Future<List<Map<String, dynamic>>> execute(Map<String, dynamic> args) async {
    var apps = await LauncherService.getDeviceApps();
    return apps.map((app) => app.toMap()).toList();
  }
}

class CurrentDateTimeTool extends Tool {
  CurrentDateTimeTool()
    : super(
        'getCurrentDateTime',
        'Call this to get the current date and time',
        {},
      );

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    return DateTime.now().toIso8601String();
  }
}
