import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:scarab/engine.dart';

@pragma('vm:entry-point')
void wakerCallback() async {
  await dotenv.load();
  DartPluginRegistrant.ensureInitialized();
  await ScarabEngine.initialize(isBackground: true);
  await ScarabEngine.run();
}

class ScarabWaker {
  static const int _wakerAlarmId = 888; // Unique ID for the waker
  static const Duration _defaultInterval = Duration(minutes: 50, seconds: 10);

  /// Starts or Resets the waker.
  /// If called while a timer is running, it cancels the old one and starts fresh.
  static Future<void> poke({Duration? duration}) async {
    final interval = duration ?? _defaultInterval;

    // By using the same ID, Android replaces any existing pending alarm
    await AndroidAlarmManager.oneShot(
      interval,
      _wakerAlarmId,
      wakerCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
    );

    print(
      "ScarabWaker: Engine scheduled to wake in ${interval.inMinutes} minutes.",
    );
  }

  static Future<void> scheduleNextDayWake() async {
    var now = DateTime.now();
    var nextDay = DateTime(now.year, now.month, now.day + 1);
    var durationUntilNextDay = nextDay.difference(now);
    await poke(duration: durationUntilNextDay);
  }

  static Future<void> sleep() async {
    await AndroidAlarmManager.cancel(_wakerAlarmId);
  }
}
