import 'package:flutter/material.dart';
import 'package:belang/core/widgets/app_back_bar.dart';
import 'package:belang/core/widgets/app_bottom_nav.dart';
import 'package:belang/features/messages/widgets/messages_search_input.dart';
import 'package:belang/features/chat/screens/chat_screen.dart';
import 'package:belang/features/profile/screens/profile-screen.dart';
import 'package:belang/data/repository/appwrite_repository.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  Future<String> _getCurrentUserId() async {
    try {
      final account = AppwriteRepository().account;
      final user = await account.get();
      print('Current user: ${user.$id}'); 
      return user.$id;
    } catch (e, st) {
      print('Error in _getCurrentUserId: ${e}\n${st}');
      rethrow;
    }
  }

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
          const MessagesSearchInput(),
          Expanded(
            child: FutureBuilder<String>(
              future: _getCurrentUserId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Could not determine user'));
                } else {
                  final currentUserId = snapshot.data!;
                  // Determine the other user
                  String targetUserId;
                  if (currentUserId == '68594f8b002a9f8fbbe8') {
                    targetUserId = '685971d60e94957c7129';
                  } else {
                    targetUserId = '68594f8b002a9f8fbbe8';
                  }
                  return ListView(
                    children: [
                      ListTile(
                        title: Text(targetUserId),
                        subtitle: const Text('Tap to chat'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                targetUserId: targetUserId,
                                targetUserName: targetUserId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),

    );
  }


}
