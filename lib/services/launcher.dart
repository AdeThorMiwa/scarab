import 'package:playx_home_launcher/playx_home_launcher.dart';
import 'package:scarab/models/device.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:permission_handler/permission_handler.dart';

class LauncherService {
  static List<DeviceApplication>? _cachedApps;

  static Future<String> getPackageName() async {
    return await PlayxHomeLauncher.getCurrentPackageName();
  }

  static Future<bool> promptSetDefaultLauncher() async {
    var hasRequiredPermissions = await requestAllPermissions();

    print("has Required permissions: $hasRequiredPermissions");

    if (!hasRequiredPermissions) {
      return false;
    }

    bool isDefault = await PlayxHomeLauncher.isThisAppTheDefaultLauncher();

    if (isDefault) {
      return true;
    }

    await PlayxHomeLauncher.showLauncherSelectionDialog();

    return await PlayxHomeLauncher.isThisAppTheDefaultLauncher();
  }

  static Future<List<DeviceApplication>> getDeviceApps() async {
    // If we already have them, return immediately
    if (_cachedApps != null) return _cachedApps!;

    var apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false,
      withIcon: false,
      excludeNonLaunchableApps: true,
    );

    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    _cachedApps = apps.map((app) {
      return DeviceApplication(name: app.name, packageId: app.packageName);
    }).toList();

    return _cachedApps!;
  }

  static Future<bool> requestAllPermissions() async {
    // 1. Notification Permission (Required for Android 13+)
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

    // 2. Access Notification Policy (Required for Do Not Disturb access on Android 13+)
    if (!await Permission.accessNotificationPolicy.isGranted) {
      await Permission.accessNotificationPolicy.request();
    }

    // 3. Battery Optimizations (Required so OS doesn't kill your Launcher)
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      print("requesting ignore battery optimizations permission");
      await Permission.ignoreBatteryOptimizations.request();
    }

    // 4. Exact Alarms (Android 14+)
    if (!await Permission.scheduleExactAlarm.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }

    // 5. System Alert Window (Required for showing the enforcement overlay)
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }

    // 6. Accessibility Permission (Required for blocking apps and showing the overlay)
    if (!(await FlutterAccessibilityService.isAccessibilityPermissionEnabled())) {
      await FlutterAccessibilityService.requestAccessibilityPermission();
    }

    print(
      "accessibility permission: ${await FlutterAccessibilityService.isAccessibilityPermissionEnabled()}",
    );
    print(
      "system alert window permission: ${await Permission.systemAlertWindow.isGranted}",
    );
    print(
      "ignore battery optimizations permission: ${await Permission.ignoreBatteryOptimizations.isGranted}",
    );

    // Return true only if the core "Enforcement" permissions are ready
    return await FlutterAccessibilityService.isAccessibilityPermissionEnabled() &&
        await Permission.systemAlertWindow.isGranted &&
        await Permission.ignoreBatteryOptimizations.isGranted;
  }
}
