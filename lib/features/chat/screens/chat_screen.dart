import 'package:flutter/material.dart';
import 'package:belang/core/widgets/app_back_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';
import 'package:belang/services/appwrite_service.dart';
import 'dart:async';
import 'package:appwrite/appwrite.dart';


class ChatScreen extends StatefulWidget {
  final String targetUserId;
  final String? targetUserName;

  const ChatScreen({Key? key, required this.targetUserId, this.targetUserName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
StreamSubscription? _subscription;
String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
_subscribeToMessages();
}

Future<void> _getCurrentUserId() async {
    try {
      final user = await AppwriteService.getCurrentUser();
      setState(() {
        _currentUserId = user.$id;
      });
      await _loadMessageHistory();
    } catch (e) {
      // Handle error (e.g., show a dialog or redirect to login)
      print('Failed to get current user: $e');
    }
  }

  Future<void> _loadMessageHistory() async {
    if (_currentUserId == null) return;
    final myUserId = _currentUserId!;
    final targetUserId = widget.targetUserId;
    try {
      final messages = await AppwriteService.getMessagesBetweenUsers(
        user1Id: myUserId,
        user2Id: targetUserId,
      );
      setState(() {
        _messages.clear();
        _messages.addAll(messages.map((msg) => {
          'text': msg.content,
          'isMe': msg.senderId == myUserId,
          'time': DateTime.tryParse(msg.createdAt) ?? DateTime.now(),
          'isRead': msg.isRead,
        }));
      });
      
      // Mark messages as read when loading conversation
      await _markMessagesAsRead();
    } catch (e) {
      print('Failed to load message history: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToMessages() {
    // Create a realtime client for listening to message updates
    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('6855dd6b003ce2cab4ff');
    final realtime = Realtime(client);
    
    // Listen for document creation in the messages collection
    _subscription = realtime.subscribe([
      'databases.685c69ca0000f9d61a7a.collections.messages.documents',
    ]).stream.listen((event) {
        if (event.events.contains('databases.*.collections.*.documents.*.create')) {
        final data = event.payload;
        // Only add messages relevant to this conversation
        if (_currentUserId == null) return;
        final myUserId = _currentUserId!;
        if ((data['senderId'] == myUserId && data['receiverId'] == widget.targetUserId) ||
            (data['senderId'] == widget.targetUserId && data['receiverId'] == myUserId)) {
setState(() {
          _messages.insert(0, {
            'text': data['content'],
            'isMe': data['senderId'] == myUserId,
'time': DateTime.tryParse(data['\$createdAt'] ?? '') ?? DateTime.now(),
            'isRead': data['isRead'] ?? false,
          });
        });

        // Mark messages as read if they are from the other user
        if (data['senderId'] == widget.targetUserId) {
          _markMessagesAsRead();
        }
        
        // Notifications are handled by the global NotificationService
        }
      } else if (event.events.contains('databases.*.collections.*.documents.*.update')) {
        // Handle message updates (like read status changes)
        final data = event.payload;
        if (_currentUserId == null) return;
        final myUserId = _currentUserId!;
        
        // Update read status for messages in this conversation
        if ((data['senderId'] == myUserId && data['receiverId'] == widget.targetUserId) ||
            (data['senderId'] == widget.targetUserId && data['receiverId'] == myUserId)) {
          setState(() {
            for (int i = 0; i < _messages.length; i++) {
              // Update the specific message if we can match it
              if (_messages[i]['time'] != null) {
                final messageTime = _messages[i]['time'] as DateTime;
final updatedTime = DateTime.tryParse(data['\$createdAt'] ?? '');
                if (updatedTime != null && 
                    messageTime.difference(updatedTime).abs().inSeconds < 2) {
                  _messages[i]['isRead'] = data['isRead'] ?? false;
                }
              }
            }
          });
        }
      }
    });
  }

  /// Mark all unread messages from the target user as read
  Future<void> _markMessagesAsRead() async {
    if (_currentUserId == null) return;
    
    try {
      await AppwriteService.markMessagesAsRead(
        currentUserId: _currentUserId!,
        otherUserId: widget.targetUserId,
      );
      
      // Update local message state to reflect read status
      setState(() {
        for (int i = 0; i < _messages.length; i++) {
          if (!_messages[i]['isMe']) {
            _messages[i]['isRead'] = true;
          }
        }
      });
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty && _currentUserId != null) {
      final senderId = _currentUserId!;
      final receiverId = widget.targetUserId;

      // Send to Appwrite
      try {
        await AppwriteService.sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          content: text,
        );
        _controller.clear();
      } catch (e) {
        // Handle error (show a snackbar, etc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: '
              + (e.toString())),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBackBar(
            title: widget.targetUserName ?? widget.targetUserId,
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