import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:scarab/session/enforcement/action.dart';
import 'package:scarab/session/session.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'enforcer.dart';

class EnforcementService {
  static Future<void> startService(Session session) async {
    print("Starting enforcer...");

    await FlutterForegroundTask.saveData(
      key: SessionEnforcer.sessionStorageKey,
      value: session.toJson(),
    );

    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.restartService();
    } else {
      FlutterForegroundTask.startService(
        serviceId: session.id.hashCode,
        notificationTitle: 'Focus session active',
        notificationText: '${session.title} is ongoing',
        callback: startCallback,
        serviceTypes: [ForegroundServiceTypes.specialUse],
        notificationInitialRoute: '/',
        notificationButtons: [
          const NotificationButton(id: 'ack', text: 'Start Session'),
        ],
      );
    }
  }

  static Future<R> sendMessage<M, R>(String sessionId, M message) async {
    if (!(await FlutterForegroundTask.isRunningService)) {
      return {"success": false, "message": "No running service"} as R;
    }

    final ReceivePort tempPort = ReceivePort();
    IsolateNameServer.registerPortWithName(tempPort.sendPort, sessionId);

    // We send the message AND the sendPort of our temporary receiver
    // so the background isolate knows how to talk back to this specific request.
    FlutterForegroundTask.sendDataToTask({
      'body': message,
      'replyPort': sessionId,
    });

    // Wait for the background task to send something back
    final Completer<R> completer = Completer<R>();

    tempPort.listen((response) {
      completer.complete(response as R);
      tempPort.close(); // Close the port once we have our answer
    });

    // Optional: Add a timeout so we don't hang forever
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        tempPort.close();
        throw TimeoutException("No response from Foreground Task");
      },
    );
  }

  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }

  static Future<Session?> getActiveSession() async {
    if (!(await FlutterForegroundTask.isRunningService)) {
      return null;
    }

    final jsonString = await FlutterForegroundTask.getData<String>(
      key: SessionEnforcer.sessionStorageKey,
    );

    if (jsonString == null) {
      return null;
    }

    return Session.fromJson(jsonString);
  }

  static Future<void> initialize({bool isBackground = false}) async {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    if (!isBackground) {
      await _requestPermissions();
    }
  }

  static void _onReceiveTaskData(Object data) {
    if (data == EnforcementAction.showOverlay) {
      FlutterAccessibilityService.showOverlayWindow();
      return;
    }

    if (data == EnforcementAction.hideOverlay) {
      FlutterAccessibilityService.hideOverlayWindow();
      return;
    }
  }

  static Future<void> _requestPermissions() async {
    NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
    }

    if (!await FlutterForegroundTask.canDrawOverlays) {
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    if (!(await FlutterAccessibilityService.isAccessibilityPermissionEnabled())) {
      await FlutterAccessibilityService.requestAccessibilityPermission();
    }
  }

  static void initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'scarab_sticky_alerts',
        channelName: 'Scarab Enforcement Service Notification',
        channelDescription:
            'This notification appears when an enforcement service running.',
        enableVibration: true,
        channelImportance: NotificationChannelImportance.MAX,
        playSound: true,
        priority: NotificationPriority.HIGH,
        showWhen: true,
        showBadge: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.once(),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }
}
