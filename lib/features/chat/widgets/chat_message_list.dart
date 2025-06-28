import 'package:flutter/material.dart';
import 'chat_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages; // Example: [{'text': 'Hi', 'isMe': true, 'time': DateTime.now()}]

  const ChatMessageList({
    Key? key,
    required this.messages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return ChatBubble(
          message: msg['text'],
          isMe: msg['isMe'],
          time: msg['time'] is DateTime ? msg['time'] : DateTime.parse(msg['time'].toString()),
          isRead: msg['isRead'], // Pass read status
        );
      },
    );
  }
}