import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scarab/ui/chat_input.dart';
import 'package:scarab/ui/daily_sessions.dart';
import 'package:scarab/ui/message_area.dart';
import '../scarab.dart';

class LauncherHome extends ConsumerStatefulWidget {
  const LauncherHome({super.key});

  @override
  LauncherHomeState createState() => LauncherHomeState();
}

class LauncherHomeState extends ConsumerState<LauncherHome> {
  late PageController _pageController;
  late FocusNode _chatFocusNode;
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _chatFocusNode = FocusNode();
    _inputController = TextEditingController();

    _chatFocusNode.addListener(() {
      if (_chatFocusNode.hasFocus) {
        _showMessages();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _showMessages() {
    if (!_pageController.hasClients) {
      return;
    }

    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
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
              const SizedBox(height: 12),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [MessageArea()],
                ),
              ),
              const SizedBox(height: 16),
              ChatInput(
                controller: _inputController,
                focusNode: _chatFocusNode,
                onSubmitted: _handleSubmitted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
