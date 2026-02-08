import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scarab/ui/pages/lock.dart';
import 'package:scarab/theme.dart';
import 'package:scarab/ui/debug.dart';
import 'package:scarab/ui/pages/home.dart';
import 'package:is_lock_screen2/is_lock_screen2.dart';
import 'package:scarab/ui/pages/session.dart';

class ScarabApp extends ConsumerStatefulWidget {
  const ScarabApp({super.key});

  @override
  ScarabAppState createState() => ScarabAppState();
}

class ScarabAppState extends ConsumerState<ScarabApp>
    with WidgetsBindingObserver {
  final bool _showDebugView = false;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user locks the phone, the app state usually moves to 'inactive' or 'paused'
    // When they turn the screen on (even if locked), it moves back to 'resumed'
    if (state == AppLifecycleState.resumed) {
      _checkLockStatus();
    }
  }

  Future<void> _checkLockStatus() async {
    bool? locked = await isLockScreen();
    setState(() {
      _isLocked = locked ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showDebugView) {
      return DebugScreen();
    }

    if (_isLocked) {
      return MaterialApp(
        title: 'Scarab',
        theme: scarabTheme,
        home: SwipeToUnlock(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Scarab',
      theme: scarabTheme,
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (ctx) => const LauncherHome(),
        "/create-session": (ctx) => CreateSessionPage(),
      },
    );
  }
}
