import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:scarab/events/event.dart';
import 'package:scarab/services/calendar/service.dart';
import 'package:scarab/models/calendar.dart';
import 'package:scarab/services/alarm/service.dart';
import 'package:scarab/services/enforcement/action.dart';
import 'package:scarab/models/session.dart';
import 'package:scarab/services/launcher.dart';
import 'package:scarab/events/bus.dart';

class NoSessionException implements Exception {}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SessionEnforcer());
}

class SessionEnforcer extends TaskHandler {
  static final String sessionStorageKey = "active_session";

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

    if (packageName == await LauncherService.getPackageName()) {
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
    var session = await _session;

    // ring the alarm like vietnam in this B!
    // await AlarmService.ring();
    _setupAccessibilityListener();
    AppEventBus.publish(SessionStartedEvent(session));
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    print('[SessionEnforcer::onRepeat] timestamp: $timestamp');
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('[SessionEnforcer::onDestroy] (isTimeout: $isTimeout)');
    await AlarmService.stop();
    var session = await _session;
    AppEventBus.publish(SessionEndedEvent(session));
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
        isFocusSession: true,
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

      if (await isOverlayDisplay(event)) {
        return;
      }

      if (isCurrentImePackage(event)) {
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

  Future<bool> isOverlayDisplay(AccessibilityEvent event) async {
    return event.packageName == await LauncherService.getPackageName() &&
        event.windowType == WindowType.typeAccessibilityOverlay;
  }

  bool isSystemUI(AccessibilityEvent event) {
    return event.packageName == "com.android.systemui";
  }

  bool isCurrentImePackage(AccessibilityEvent event) {
    return event.packageName?.contains("android.inputmethod") ?? false;
  }
}
