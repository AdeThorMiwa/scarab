import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:scarab/session/enforcement/service.dart';
import 'package:scarab/session/reminder.dart';
import 'package:scarab/session/session.dart';

@pragma('vm:entry-point')
void beginSession(int id, Map<String, dynamic> map) async {
  DartPluginRegistrant.ensureInitialized();
  EnforcementService.initService();

  var session = Session.fromMap(map);
  await EnforcementService.startService(session);
}

class SessionService {
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> startSession(Session session) async {
    await ReminderService.setSessionReminders(session);
    await _scheduleSession(session);
  }

  static Future<void> stopSession(Session session) async {
    await AndroidAlarmManager.cancel(session.id.hashCode);
    await ReminderService.cancelSessionPendingReminders(session);
    await EnforcementService.stopService();
  }

  static Future<R> sendMessageToSession<R>(
    String sessionId,
    Map<String, dynamic> message,
  ) async {
    return await EnforcementService.sendMessage(sessionId, message);
  }

  static Future<void> _scheduleSession(Session session) async {
    if (await getActiveSession() != null) {
      print("A session is already active. Cannot schedule another.");
      return;
    }

    final int alarmId = session.id.hashCode;

    var time = _getStartTime(session.start);

    print(" scheduling session ${session.id} at $time");

    await AndroidAlarmManager.oneShotAt(
      time,
      alarmId,
      beginSession, // Top-level function
      params: session.toMap(),
      alarmClock: true,
    );
  }

  static Future<Session?> getActiveSession() async {
    return await EnforcementService.getActiveSession();
  }

  static DateTime _getStartTime(DateTime time) {
    if (time.isAfter(DateTime.now())) {
      return time;
    }

    return DateTime.now().add(Duration(seconds: 1));
  }
}
