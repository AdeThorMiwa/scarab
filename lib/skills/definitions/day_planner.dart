import 'package:scarab/skills/skill.dart';
import 'package:scarab/tools/tool.dart';
import 'package:scarab/tools/calendar/get_events.dart';
import 'package:scarab/tools/calendar/create_event.dart';
import 'package:scarab/tools/focus/create_focus_session.dart';
import 'package:scarab/tools/device/get_apps.dart';
import 'package:scarab/tools/device/current_datetime.dart';

class DayPlannerSkill extends Skill {
  @override
  String get id => 'day_planner';

  @override
  String get name => 'Day Planner';

  @override
  String get description =>
      "Plan and schedule the user's day by distributing tasks across available time slots";

  @override
  String get contextPrompt =>
      '''You are planning the user's day by scheduling tasks on their calendar.

IMPORTANT: Your FIRST action on every task must be to call get_current_date_time and get_device_apps. You need the current time to resolve relative references like "today", "tomorrow", etc., and the app list to set up focus sessions. Never ask the user what the date is — use the tools.

After getting context, follow this process:
1. Fetch the relevant day's existing calendar events to see what's already booked
2. Optionally fetch the past 1-2 weeks of events to identify patterns (typical work hours, break habits, task durations)
3. Distribute the user's tasks across available time slots, considering:
   - Task priority and type
   - Energy levels throughout the day (high-focus tasks earlier)
   - Breaks between tasks (10-15 min buffer)
   - Existing commitments that can't be moved
   - Historical patterns if available
4. Present the proposed schedule clearly in a table or list format
5. Wait for the user's confirmation before creating any events
6. Once confirmed, schedule each task

IMPORTANT — Default to focus sessions:
- By default, use create_focus_session for every task. Focus sessions block distracting apps and help the user stay productive.
- For each task, determine which apps the user would need (e.g., coding needs an IDE, reading needs a reader app) and set those as allowedApps.
- Only use create_calendar_event (plain calendar event) if the user explicitly says they don't want app blocking for a specific task.

Group similar tasks when possible. Don't over-schedule — leave breathing room.
If the user provides specific times for some tasks, honor those and schedule the rest around them.
Always show the full proposed schedule before committing.''';

  @override
  List<Tool> get tools => [
    GetCalendarEventsTool(),
    CreateCalendarEventTool(),
    CreateFocusSessionTool(),
    GetDeviceAppsTool(),
    CurrentDateTimeTool(),
  ];
}
