import 'package:flutter/material.dart';
import 'package:scarab/services/launcher.dart';
import 'package:scarab/ui/overlay.dart';
import 'package:scarab/ui/debug.dart';
import 'package:scarab/ui/home.dart';
import 'services/backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
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
  // bool isDefault = await LauncherService.promptSetDefaultLauncher();

  // if (isDefault) {
  //   await ScarabBackendService.initialize();
  // }

  runApp(ProviderScope(child: MyApp()));
  // await ScarabBackendService.run();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final bool showDebugView = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (showDebugView) {
      return DebugScreen();
    }

    return MaterialApp(
      title: 'Scarab',
      theme: scarabTheme,
      home: LauncherHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
