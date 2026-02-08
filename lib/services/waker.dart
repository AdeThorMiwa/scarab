import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:scarab/services/backend.dart';

@pragma('vm:entry-point')
void wakerCallback() async {
  await dotenv.load();
  DartPluginRegistrant.ensureInitialized();
  await ScarabBackendService.initialize(isBackground: true);
  await ScarabBackendService.run();
}

class WakerService {
  static const int _wakerAlarmId = 888; // Unique ID for the waker
  static const Duration _defaultDelay = Duration(minutes: 50, seconds: 10);

  static Future<void> wake({Duration? delayUntil, DateTime? datetime}) async {
    var delay = delayUntil;

    if (delay == null && datetime != null) {
      delay = datetime.difference(DateTime.now());
    }

    delay ??= _defaultDelay;

    // By using the same ID, Android replaces any existing pending alarm
    await AndroidAlarmManager.oneShot(
      delay,
      _wakerAlarmId,
      wakerCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
    );

    print(
      "ScarabWaker: Engine scheduled to wake in ${delay.inMinutes} minutes.",
    );
  }

  static Future<void> scheduleNextDayWake() async {
    var now = DateTime.now();
    var nextDay = DateTime(now.year, now.month, now.day + 1);
    var durationUntilNextDay = nextDay.difference(now);
    print("Nothing to do today, wake tommorow");
    await wake(delayUntil: durationUntilNextDay);
  }

  static Future<void> sleep() async {
    await AndroidAlarmManager.cancel(_wakerAlarmId);
  }
}
