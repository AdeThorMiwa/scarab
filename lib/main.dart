import 'package:flutter/material.dart';
import 'package:scarab/app.dart';
import 'package:scarab/services/launcher.dart';
import 'package:scarab/ui/overlay.dart';
import 'services/backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma("vm:entry-point")
void accessibilityOverlay() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: const MaterialApp(
        home: ScarabOverlay(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LauncherService.promptSetDefaultLauncher();
  await ScarabBackendService.initialize();
  runApp(ProviderScope(child: ScarabApp()));
  await ScarabBackendService.run();
}
