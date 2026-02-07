import 'package:scarab/calendar/service.dart';
import 'package:scarab/main.dart';
import 'package:scarab/scarab.dart';
import 'package:scarab/session/enforcement/service.dart';
import 'package:scarab/session/manager.dart';
import 'package:scarab/session/reminder.dart';
import 'package:scarab/session/session.dart';
import 'package:scarab/waker.dart';
import 'utils/consts.dart';

class ScarabEngine {
  static Future<void> initialize({bool isBackground = false}) async {
    await EnforcementService.initialize(isBackground: isBackground);
    await ReminderService.initialize(isBackground: isBackground);
    await SessionService.initialize();
  }

  static Future<void> run() async {
    // do some work
    await _prepareNextSession();
  }

  static Future<void> _prepareNextSession() async {
    var nextEvents = await CalendarService.getNextEvents(
      calendarId: calendarId,
      size: 3,
    );

    if (nextEvents.isEmpty) {
      print("No upcoming events found. Engine will sleep until next day.");
      // sleep engine till next day
      // await ScarabWaker.scheduleNextDayWake();
      return;
    }

    print("Fetched next events: ${nextEvents.map((e) => e.title).toList()}");

    var nextEvent = nextEvents.first;

    // i need to set upcoming events here
    globalContainer
        .read(scarabProvider.notifier)
        .setUpcomingEvents(nextEvents.sublist(1)); // set the rest as upcoming

    print("event: ${nextEvent.toMap()}");

    var session = Session.fromCalendarEvent(nextEvent);

    print("session: ${session.toMap()}");
    await SessionService.startSession(session);
    // schedule waker for 5 minutes before session end
    var fiveMinutesBeforeEnd = session.end.subtract(Duration(minutes: 5));
    if (fiveMinutesBeforeEnd.isBefore(DateTime.now())) {
      print(" end is less than 5 minutes away");
      // if session ends in less than 5 minutes, poke immediately
      await ScarabWaker.poke();
      return;
    }

    ScarabWaker.poke(duration: fiveMinutesBeforeEnd.difference(DateTime.now()));
  }
}
