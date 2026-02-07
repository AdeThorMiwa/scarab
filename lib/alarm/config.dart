class AlarmConfig {
  final String? assetPath;
  final bool loop;
  final double volume; // 0.0 - 1.0
  final bool vibrate;
  final List<int>? vibrationPattern; // ms pattern
  final Duration? fadeIn;

  const AlarmConfig({
    this.assetPath,
    this.loop = true,
    this.volume = 1.0,
    this.vibrate = true,
    this.vibrationPattern,
    this.fadeIn,
  });
}
