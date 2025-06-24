import 'package:flutter/material.dart';
import 'package:lango/core/widgets/app_back_bar.dart';
import 'package:lango/core/widgets/app_bottom_nav.dart';
import 'package:lango/features/messages/widgets/messages_search_input.dart';
import 'package:lango/features/chat/screens/chat_screen.dart';
import 'package:lango/features/profile/screens/profile-screen.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBackBar(
            title: 'Message',
            backIcon: 'assets/icons/ic_arrow_back.svg',
            actionIcon: 'assets/icons/ic_shield_check.svg',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
  const MessagesSearchInput(),
  Expanded(
    child: Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChatScreen(),
              ),
            );
          },
          child: const Text('Open Chat'),
        ),
        const Expanded(
          child: Center(
            child: Text('Messages List will go here'),
          ),
        ),
      ],
    ),
  ),
],
              ),
            ),
          ),
        ],
      ),

    );
  }


}
