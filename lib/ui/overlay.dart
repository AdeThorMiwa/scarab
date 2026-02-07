import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class ScarabOverlay extends StatelessWidget {
  const ScarabOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // canvas type forces the engine to create a drawing layer
      type: MaterialType.canvas,
      color: const Color(0xFF0B0C0E), // deep dark blue
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Locked by Scarab",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => LaunchApp.openApp(
                      androidPackageName: 'com.example.scarab',
                    ),
                    child: const Text("Return to Scarab"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
