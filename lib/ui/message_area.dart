import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scarab/models/chat_message.dart';
import 'state/scarab.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageArea extends ConsumerWidget {
  const MessageArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    final isThinking = ref.watch(scarabProvider.select((s) => s.isThinking));

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.hardEdge,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1113),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1A1E23)),
        ),
        child: Stack(
          // Use a Stack to overlay the loader
          children: [
            _MessageList(messages: messages),
            if (isThinking)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
                  minHeight: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Ask Scarab to begin.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A8F98)),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      reverse: true,
      primary: false,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return _MessageBubble(
          author: message.author,
          text: message.text,
          isUser: message.isUser,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.author,
    required this.text,
    required this.isUser,
  });

  final String author;
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? const Color(0xFF1A2A21)
        : const Color(0xFF13161A);
    final borderColor = isUser
        ? const Color(0xFF2A4A38)
        : const Color(0xFF1D2228);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // Markdown handles its own internal layout, so we give it a bit more room
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Left align text inside bubble
          children: [
            Text(
              author,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF8A8F98),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            MarkdownBody(
              data: text,
              selectable: true, // Allows users to copy code blocks easily
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                code: const TextStyle(
                  backgroundColor: Color(0xFF1E2127),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFFE5C07B), // Warm code color
                ),
                codeblockDecoration: BoxDecoration(
                  color: const Color(0xFF1E2127),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2C313A)),
                ),
                blockquote: const TextStyle(color: Colors.grey),
                blockquoteDecoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                listBullet: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
