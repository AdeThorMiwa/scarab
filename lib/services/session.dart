import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:scarab/services/enforcement/service.dart';
import 'package:scarab/services/reminder.dart';
import 'package:scarab/models/session.dart';

@pragma('vm:entry-point')
void beginSession(int id, Map<String, dynamic> map) async {
  DartPluginRegistrant.ensureInitialized();
  var session = Session.fromMap(map);
  EnforcementService.initService(session.id);
  await EnforcementService.startService(session);
}

@pragma('vm:entry-point')
void endSession(int id, Map<String, dynamic> map) async {
  DartPluginRegistrant.ensureInitialized();
  var session = Session.fromMap(map);
  EnforcementService.initService(session.id);
  await SessionService.killSession(session);
}

class SessionService {
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> startSession(Session session) async {
    await ReminderService.setSessionReminders(session);
    await _scheduleSession(session);
  }

  static Future<void> killSession(Session session) async {
    await AndroidAlarmManager.cancel(session.id.hashCode);
    await ReminderService.cancelSessionPendingReminders(session);
    await EnforcementService.stopService();
  }

  static Future<void> scheduleSessionStop(Session session) async {
    AndroidAlarmManager.oneShotAt(
      session.end.subtract(Duration(seconds: 20)),
      session.id.hashCode + 100,
      endSession,
      alarmClock: true,
      params: session.toMap(),
    );
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
