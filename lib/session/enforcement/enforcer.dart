import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:scarab/calendar/service.dart';
import 'package:scarab/models/calendar.dart';
import 'package:scarab/session/alarm.dart';
import 'package:scarab/session/enforcement/action.dart';
import 'package:scarab/session/session.dart';

class NoSessionException implements Exception {}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SessionEnforcer());
}

class SessionEnforcer extends TaskHandler {
  static final String sessionStorageKey = "active_session";
  static final String scarabPackageName = "com.example.scarab";

  Future<Session> get _session async {
    final json = await FlutterForegroundTask.getData<String>(
      key: sessionStorageKey,
    );

    if (json == null) {
      throw NoSessionException();
    }

    return Session.fromJson(json);
  }

  Future<bool> isBlocked(String? packageName) async {
    var session = await _session;

    if (packageName == null || packageName.isEmpty) {
      return false;
    }

    if (packageName == scarabPackageName) {
      return false;
    }

    print("allowedApps: ${session.allowedApps} packageName: $packageName");

    // If the app is NOT in the allowed list, it is blocked
    return !session.allowedApps.contains(packageName);
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("[SessionEnforcer::onStart]");

    // ring the alarm like vietnam in this B!
    await AlarmService.ring();
    _setupAccessibilityListener();
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('[SessionEnforcer::onDestroy] (isTimeout: $isTimeout)');
    await AlarmService.stop();
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) async {
    if (id == "ack") {
      await onAcknowledge();
    }
  }

  Future<void> onAcknowledge() async {
    await AlarmService.stop();
    FlutterForegroundTask.launchApp("/");
  }

  @override
  void onReceiveData(Object data) async {
    print("[SessionEnforcer::onReceiveData]");
    if (data is! Map || !data.containsKey('replyPort')) {
      return;
    }

    final Map<String, dynamic> body = data['body'];
    final SendPort? replyPort = IsolateNameServer.lookupPortByName(
      data['replyPort'],
    );

    // Perform your logic based on the command
    try {
      final response = await _handleCommand(body);
      replyPort?.send(response);
    } catch (e) {
      replyPort?.send({"success": false, "error": e.toString()});
    }
  }

  Future<T> _handleCommand<T>(Map<String, dynamic> input) async {
    Map<String, dynamic> response = {"success": true};

    if (input["command"] == "log") {
      print("[SessionEnforcer::logger] ${input["message"]}");
    }

    if (input["command"] == "createFocusSession") {
      final req = AddEventToCalendarRequest(
        title: input["title"],
        description: input["description"],
        startTime: DateTime.fromMillisecondsSinceEpoch(input["startTime"]),
        endTime: DateTime.fromMillisecondsSinceEpoch(input["endTime"]),
        allowedApps: List<String>.from(input["allowedApps"] ?? []),
        isFreeTime: input["isFreeTime"],
      );

      await CalendarService.addEventToCalendar(req);
      response["message"] = "Event created successfully";
    }

    return response as T;
  }

  void _setupAccessibilityListener() {
    FlutterAccessibilityService.accessStream.listen((event) async {
      // We only care about window state changes (app switches)
      if (event.eventType != EventType.typeWindowStateChanged) {
        return;
      }

      if (event.packageName == null) {
        return;
      }

      print(
        "[SessionEnforcer::accessibility] new event for package: ${event.packageName}",
      );

      if (isOverlayDisplay(event)) {
        return;
      }

      if (await isCurrentImePackage(event)) {
        return;
      }

      if (isSystemUI(event)) {
        FlutterAccessibilityService.performGlobalAction(
          GlobalAction.globalActionDismissNotificationShade,
        );
        return;
      }

      if (await isBlocked(event.packageName)) {
        FlutterForegroundTask.sendDataToMain(EnforcementAction.showOverlay);
      } else {
        FlutterForegroundTask.sendDataToMain(EnforcementAction.hideOverlay);
      }
    });
  }

  bool isOverlayDisplay(AccessibilityEvent event) {
    return event.packageName == scarabPackageName &&
        event.windowType == WindowType.typeAccessibilityOverlay;
  }

  bool isSystemUI(AccessibilityEvent event) {
    return event.packageName == "com.android.systemui";
  }

  Future<bool> isCurrentImePackage(AccessibilityEvent event) async {
    try {
      // You'll need a tiny MethodChannel or a plugin that reads Secure Settings
      // If you don't have one, 'native_settings' is a good choice.
      var platform = MethodChannel('$scarabPackageName/settings');
      final String? ime = await platform.invokeMethod(
        'getSecureSetting',
        'default_input_method',
      );

      print("ime: $ime");

      // Equivalent of substringBefore('/')
      var imePackage = ime?.split('/').first;

      return event.packageName == imePackage;
    } catch (e) {
      print("error checking IME package: $e");

      return event.packageName?.contains("android.inputmethod") ?? false;
    }
  }
}
