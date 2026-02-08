import 'package:scarab/services/alarm/config.dart';
import 'package:scarab/services/alarm/controller.dart';

class AlarmService {
  static Future<void> ring() async {
    var config = AlarmConfig(
      assetPath: "assets/audio/alarm.mp3",
      loop: true,
      vibrate: true,
      volume: 1,
    );
    AlarmController().ring(config);
  }

  static Future<void> stop() async {
    AlarmController().stop();
  }
}
