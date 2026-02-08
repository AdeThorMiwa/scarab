import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LockScreenClock extends StatelessWidget {
  const LockScreenClock({super.key});

  Stream<DateTime> clockStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: clockStream(),
      builder: (context, snapshot) {
        // Fallback to current time if stream hasn't started
        final time = snapshot.data ?? DateTime.now();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Clock
            Text(
              DateFormat('HH:mm').format(time), // Use 'jm' for 12h format
              style: const TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
            // Date
            Text(
              DateFormat('EEEE, MMMM d').format(time),
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withAlpha(90),
                letterSpacing: 1.2,
              ),
            ),
          ],
        );
      },
    );
  }
}
