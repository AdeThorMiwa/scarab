import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scarab/ui/clock.dart';

class SwipeToUnlock extends StatefulWidget {
  const SwipeToUnlock({super.key});

  @override
  State<SwipeToUnlock> createState() => _SwipeToUnlockState();
}

class _SwipeToUnlockState extends State<SwipeToUnlock>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  static const double _unlockThreshold = 200.0;
  static const platform = MethodChannel('scarab/system');

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      // We only care about upward movement (negative delta)
      _dragOffset -= details.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0; // Prevent dragging downwards
    });
  }

  void _handleDragEnd(DragEndDetails details) async {
    if (_dragOffset > _unlockThreshold) {
      // Trigger the native unlock prompt
      try {
        await platform.invokeMethod('requestUnlock');
      } catch (e) {
        debugPrint("Unlock failed: $e");
      }
    }

    // Reset the UI
    setState(() => _dragOffset = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LockScreenClock(),
                  Text(
                    "Focus Session Active",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: Offset(0, -_dragOffset),
              child: Opacity(
                opacity: (1 - (_dragOffset / 400)).clamp(0.0, 1.0),
                child: Container(
                  color: Colors.transparent, // Or a subtle gradient
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white70,
                        size: 30,
                      ),
                      Text(
                        "Swipe up to unlock",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
