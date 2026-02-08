import 'package:scarab/services/calendar/event.dart';
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/events/bus.dart';
import 'package:scarab/events/event.dart';
import 'package:scarab/services/enforcement/service.dart';
import 'package:scarab/services/session.dart';
import 'package:scarab/services/reminder.dart';
import 'package:scarab/models/session.dart';
import 'package:scarab/services/waker.dart';
import '../utils/consts.dart';

class ScarabBackendService {
  static bool _initialized = false;

  static Future<void> initialize({bool isBackground = false}) async {
    await EnforcementService.initialize(isBackground: isBackground);
    await ReminderService.initialize(isBackground: isBackground);
    await SessionService.initialize();
    _initialized = true;
  }

  static Future<void> run() async {
    if (!_initialized) {
      print("ScarabBackendService is not initialized");
      return;
    }

    var events = await CalendarService.getNextEvents(
      calendarId: calendarId,
      size: 2,
    );

    if (events.isEmpty) {
      await WakerService.scheduleNextDayWake();
      return;
    }

    await _prepareNextSession(events.first);

    AppEventBus.publish(UpcomingEventsSyncEvent(events));
    if (events.lastOrNull != null) {
      await _scheduleWake(events.last);
    } else {
      await WakerService.scheduleNextDayWake();
    }
  }

  static Future<void> _prepareNextSession(CalendarEvent event) async {
    var session = Session.fromCalendarEvent(event);
    await SessionService.startSession(session);
    await SessionService.scheduleSessionStop(session);
  }

  // wake 1 minute before the first reminder offset, so we can setup events
  static Future<void> _scheduleWake(CalendarEvent event) async {
    var session = Session.fromCalendarEvent(event);
    var firstReminder = session.reminderOffsets.reduce(
      (value, offset) => offset > value ? value : offset,
    );
    var wakeTime = session.start.subtract(Duration(minutes: firstReminder - 1));
    WakerService.wake(datetime: wakeTime);
  }
}
