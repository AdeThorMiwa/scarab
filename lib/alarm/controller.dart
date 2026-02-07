import 'dart:async';

import 'package:scarab/alarm/config.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:vibration/vibration.dart';

enum AlarmState { idle, ringing }

class AlarmController {
  static final AlarmController _instance = AlarmController._();
  factory AlarmController() => _instance;
  AlarmController._();

  AlarmState _state = AlarmState.idle;

  final _audio = _AudioEngine();
  final _vibration = _VibrationEngine();

  Future<void> ring(AlarmConfig config) async {
    if (_state == AlarmState.ringing) return;

    _state = AlarmState.ringing;

    if (config.vibrate) _vibration.start(config);

    if (config.assetPath != null) unawaited(_audio.start(config));
  }

  Future<void> stop() async {
    if (_state == AlarmState.idle) return;

    await _audio.stop();
    _vibration.stop();

    _state = AlarmState.idle;
  }
}

class _AudioEngine {
  final _player = AudioPlayer();

  Future<void> start(AlarmConfig config) async {
    final session = await AudioSession.instance;

    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm, // KEY
        ),
      ),
    );

    await session.setActive(true);

    await _player.setLoopMode(config.loop ? LoopMode.one : LoopMode.off);

    if (config.assetPath != null) {
      await _player.setAsset(config.assetPath!, preload: true);
    }

    if (config.fadeIn != null) {
      await _fadeIn(config.volume, config.fadeIn!);
    } else {
      await _player.setVolume(config.volume);
      await _player.play();
    }
  }

  Future<void> _fadeIn(double target, Duration duration) async {
    await _player.setVolume(0);
    await _player.play();

    const steps = 20;
    final stepTime = duration.inMilliseconds ~/ steps;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepTime));
      await _player.setVolume(target * (i / steps));
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }
}

class _VibrationEngine {
  void start(AlarmConfig config) async {
    if (!(await Vibration.hasVibrator())) return;

    Vibration.vibrate(pattern: [500, 500], repeat: 0);
  }

  void stop() {
    print("stopping vibe");
    Vibration.cancel();
  }
}
