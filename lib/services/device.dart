import 'package:scarab/models/app.dart';
import 'package:installed_apps/installed_apps.dart';

class DeviceService {
  static Future<List<DeviceApplication>> getInstalledApps() async {
    var apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false,
      withIcon: false,
      excludeNonLaunchableApps: true,
    );

    // Sort alphabetically by name
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return apps.map((app) {
      return DeviceApplication(name: app.name, packageId: app.packageName);
    }).toList();
  }
}
