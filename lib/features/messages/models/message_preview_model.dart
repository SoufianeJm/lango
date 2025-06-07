enum MessageStatus { sent, delivered, read }

class MessagePreview {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final DateTime timestamp;
  final bool isOnline;
  final int unreadCount;
  final MessageStatus status;

  MessagePreview({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timestamp,
    required this.isOnline,
    required this.unreadCount,
    required this.status,
  });
}
