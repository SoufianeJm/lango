// Moved from starter-for-flutter/lib/data/models/message.dart

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final String id;
  final String createdAt;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.id,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      id: map['\$id'] ?? '',
      createdAt: map['\$createdAt'] ?? '',
    );
  }
}
