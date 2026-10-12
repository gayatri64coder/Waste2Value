enum MessageSender {
  user,
  bot,
  system;
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final List<String> suggestions;
  final String? topicTag;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.suggestions = const [],
    this.topicTag,
  });
}
