import 'package:scarab/models/session.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const alertChannel = "scarab_alerts";

  static Future<void> initialize({bool isBackground = false}) async {
    await _configureLocalTimeZone();
    await _initializeNotificationPlugin();
  }

  static Future<void> setSessionReminders(Session session) async {
    if (session.reminderOffsets.isEmpty) {
      return;
    }

    for (final offset in session.reminderOffsets) {
      await setReminder(
        session.id,
        session.start.subtract(Duration(minutes: offset)),
        title: "Session starting soon",
        body: "${session.title} begins in $offset minutes",
        urgent: true,
        suffix: offset,
      );
    }
  }

  static Future<void> cancelSessionPendingReminders(Session session) async {
    if (session.reminderOffsets.isEmpty) {
      return;
    }

    for (final offset in session.reminderOffsets) {
      await cancelReminder(session.id, suffix: offset);
    }
  }

  static Future<void> setReminder(
    String id,
    DateTime triggerAt, {
    required String title,
    required String body,
    required bool urgent,
    int? suffix,
  }) async {
    if (triggerAt.isBefore(DateTime.now())) {
      // no need scheduling
      return;
    }

    final nid = _alarmId(id, suffix: suffix);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        alertChannel,
        'Scarab Notifications',
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: true,
        timeoutAfter: 60000, // TODO: make configurable
        fullScreenIntent: urgent,
        category: urgent ? AndroidNotificationCategory.alarm : null,
        enableVibration: urgent,
        channelBypassDnd: urgent,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: nid,
      scheduledDate: tz.TZDateTime.from(triggerAt, tz.local),
      title: title,
      body: body,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> cancelReminder(String id, {int? suffix}) async {
    final nid = _alarmId(id, suffix: suffix);
    await _plugin.cancel(id: nid);
  }

  static int _alarmId(String target, {int? suffix}) {
    final base = target.hashCode & 0x7fffffff;
    final salt = suffix != null ? (suffix % 100) + 10 : 0;
    return base + 0 + salt;
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  static Future<void> _initializeNotificationPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(settings: initializationSettings);
  }
}
