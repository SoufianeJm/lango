import 'package:flutter/material.dart';
import 'package:lango/core/widgets/app_back_bar.dart';
import 'package:lango/core/widgets/app_bottom_nav.dart';
import 'package:lango/features/messages/widgets/messages_search_input.dart';

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
                children: const [
                  MessagesSearchInput(),
                  Expanded(
                    child: Center(
                      child: Text('Messages List will go here'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: _onBottomNavTap,
      ),
    );
  }

  static void _onBottomNavTap(int index) {
    print('Bottom nav tapped: $index');
  }
}
