// Moved from starter-for-flutter/lib/data/models/message.dart

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final String id;
  final String createdAt;
  final String? conversationId;
  final bool isRead;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.id,
    required this.createdAt,
    this.conversationId,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      id: map['\$id'] ?? '',
      createdAt: map['timestamp'] ?? map['\$createdAt'] ?? '', // Use timestamp field from your DB
      conversationId: map['conversationId'],
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'conversationId': conversationId,
      'isRead': isRead,
      'timestamp': createdAt,
    };
  }
}
