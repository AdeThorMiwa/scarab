class ChatMessage {
  const ChatMessage({
    required this.author,
    required this.text,
    required this.isUser,
  });

  final String author;
  final String text;
  final bool isUser;
}
