import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInput extends ConsumerWidget {
  const ChatInput({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.onSubmitted,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.send,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: const InputDecoration(
        hintText: 'Ask Scarab to open or do something...',
        prefixIcon: Icon(Icons.search, size: 20),
      ),
      onSubmitted: onSubmitted,

    );
  }
}
