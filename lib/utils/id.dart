import 'dart:math';

String generateHexString([int length = 32]) {
  final Random random = Random();
  final values = List<int>.generate(length, (i) => random.nextInt(256));

  return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
}
