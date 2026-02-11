import 'package:scarab/services/launcher.dart';
import 'package:scarab/tools/tool.dart';

class GetDeviceAppsTool extends Tool {
  GetDeviceAppsTool()
    : super(
        'get_device_apps',
        'Call this to get a list of all apps on the device',
        {},
      );

  @override
  Future<List<Map<String, dynamic>>> execute(Map<String, dynamic> args) async {
    var apps = await LauncherService.getDeviceApps();
    return apps.map((app) => app.toMap()).toList();
  }
}
