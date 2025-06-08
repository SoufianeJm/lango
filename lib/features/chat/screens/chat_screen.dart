import 'package:flutter/material.dart';
import 'package:lango/core/widgets/app_back_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.insert(0, {'text': text, 'isMe': true, 'time': DateTime.now()});
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBackBar(
            title: 'Chat',
            backIcon: 'assets/icons/ic_arrow_back.svg',
            actionIcon: 'assets/icons/ic_shield_check.svg',
          ),
          Expanded(
            child: ChatMessageList(messages: _messages),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatInputField(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}