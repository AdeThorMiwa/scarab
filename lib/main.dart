import 'package:flutter/material.dart';
import 'package:scarab/ui/overlay.dart';
import 'package:scarab/ui/debug.dart';
import 'package:scarab/ui/home.dart';
import 'engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late ProviderContainer globalContainer;

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
  globalContainer = ProviderContainer();

  await ScarabEngine.initialize();

  runApp(UncontrolledProviderScope(container: globalContainer, child: MyApp()));
  await ScarabEngine.run();
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
      theme: ThemeData(
        fontFamily: "Digital",
        brightness: Brightness.dark,
        colorScheme: scarabColorScheme,
        scaffoldBackgroundColor: const Color(
          0xFF040608,
        ), // Deep "Alien Void" Black
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(
            0xFF0D141C,
          ), // Deep Metallic Navy (Armor Plate)
          hintStyle: const TextStyle(
            color: Color(0xFF38B6FF), // Bioluminescent Cyan (Glow effect)
            fontWeight: FontWeight.w300,
          ),
          labelStyle: const TextStyle(color: Color(0xFF00E5FF)),

          // Outer border with the "glowing line" effect
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF00E5FF).withValues(alpha: .3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: LauncherHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
