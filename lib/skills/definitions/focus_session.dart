import 'package:scarab/skills/skill.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/tools/focus/create_focus_session.dart';
import 'package:scarab/tools/device/get_apps.dart';
import 'package:scarab/tools/device/current_datetime.dart';
import 'package:scarab/tools/calendar/get_events.dart';

class FocusSessionSkill extends Skill {
  @override
  String get id => 'focus_session';

  @override
  String get name => 'Focus Sessions';

  @override
  String get description =>
      'Create focus sessions that block distracting apps on the device';

  @override
  String get contextPrompt =>
      '''You are creating focus sessions that enforce app blocking on the user's device.

IMPORTANT: Always call get_current_date_time and get_device_apps first before doing anything else. You need the current time to schedule sessions and the app list to validate package IDs. Never ask the user what the date is or guess app IDs — use the tools.

When the user wants to focus:
1. Ask clarifying questions: what work, how long, which apps they need
2. Only allow apps necessary for the stated goal — keep the list minimal
3. Check existing calendar events to avoid conflicts
4. Create the focus session with a clear title and description

Do NOT guess app package IDs. If an app isn't in the device app list, tell the user and ask for alternatives.
Explain what you're doing before creating a session (e.g., "I'm blocking everything except Chrome and Slack for 2 hours.").''';

  @override
  List<Tool> get tools => [
    CreateFocusSessionTool(),
    GetDeviceAppsTool(),
    CurrentDateTimeTool(),
    GetCalendarEventsTool(),
  ];
}
