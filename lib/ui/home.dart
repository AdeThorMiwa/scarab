import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scarab/ui/chat_input.dart';
import 'package:scarab/ui/daily_sessions.dart';
import 'package:scarab/ui/message_area.dart';
import 'state/scarab.dart';

class LauncherHome extends ConsumerStatefulWidget {
  const LauncherHome({super.key});

  @override
  LauncherHomeState createState() => LauncherHomeState();
}

class LauncherHomeState extends ConsumerState<LauncherHome> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  void _handleSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final notifier = ref.read(scarabProvider.notifier);
    notifier.sendPrompt(trimmed);
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DailySessions(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: MessageArea(),
                ),
              ),
              ChatInput(
                controller: _inputController,
                onSubmitted: _handleSubmitted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
