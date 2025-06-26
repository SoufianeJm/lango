class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageTime;
  final String createdAt;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['\$id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'createdAt': createdAt,
    };
  }
}
