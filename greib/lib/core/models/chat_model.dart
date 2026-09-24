class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime? timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.timestamp,
    this.isRead = false,
  });
}

class ChatConversation {
  final String id;
  final String title;
  final List<String> participantIds;
  final List<ChatMessage> messages;
  final String type;
  final String? createdBy;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.messages,
    required this.type,
    this.createdBy,
  });
}
