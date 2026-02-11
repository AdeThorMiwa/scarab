import 'package:scarab/skills/skill.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/tools/calendar/get_events.dart';
import 'package:scarab/tools/calendar/create_event.dart';
import 'package:scarab/tools/calendar/update_event.dart';
import 'package:scarab/tools/calendar/delete_event.dart';
import 'package:scarab/tools/device/current_datetime.dart';

class CalendarSkill extends Skill {
  @override
  String get id => 'calendar';

  @override
  String get name => 'Calendar Management';

  @override
  String get description => 'Query, create, update, and delete calendar events';

  @override
  String get contextPrompt => '''You are managing the user's Google Calendar.
You can read events, create new ones, update existing ones, and delete events.

IMPORTANT: Always call get_current_date_time first to know the current date and time. Use this to resolve relative references like "today", "tomorrow", "next week", etc. Never ask the user what the date is — use the tool.

Always confirm destructive actions (update/delete) with the user before executing.
Use ISO 8601 for all timestamps. Respect existing events and check for conflicts.
When listing events, format them clearly with time, title, and description.
If the user asks what's on their calendar, fetch events for the relevant time range.''';

  @override
  List<Tool> get tools => [
    GetCalendarEventsTool(),
    CreateCalendarEventTool(),
    UpdateCalendarEventTool(),
    DeleteCalendarEventTool(),
    CurrentDateTimeTool(),
  ];
}
