import 'package:flutter/material.dart';
import 'package:belang/core/widgets/app_back_bar.dart';
import 'package:belang/features/chat/screens/chat_screen.dart';
import 'package:belang/services/appwrite_service.dart';
import 'package:belang/data/models/user.dart';
import 'package:belang/data/models/message.dart';
import 'package:belang/features/messages/screens/user_list_screen.dart';
import 'package:belang/core/themes/app_colors.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class ConversationPreview {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isLastMessageFromMe;

  ConversationPreview({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isLastMessageFromMe,
  });
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  List<ConversationPreview> _conversations = [];
  String? _currentUserId;
  bool _isLoading = true;
  String _searchQuery = '';
  List<ConversationPreview> _filteredConversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      // Get current user ID
      final currentUser = await AppwriteService.getCurrentUser();
      _currentUserId = currentUser.$id;

      // Get all messages where current user is either sender or receiver
      final allMessages = await AppwriteService.getAllMessagesForUser(_currentUserId!);
      
      // Group messages by conversation partner
      Map<String, List<Message>> conversationGroups = {};
      
      for (var message in allMessages) {
        String otherUserId;
        if (message.senderId == _currentUserId) {
          otherUserId = message.receiverId;
        } else {
          otherUserId = message.senderId;
        }
        
        if (!conversationGroups.containsKey(otherUserId)) {
          conversationGroups[otherUserId] = [];
        }
        conversationGroups[otherUserId]!.add(message);
      }
      
      List<ConversationPreview> conversationPreviews = [];
      
      for (var entry in conversationGroups.entries) {
        final otherUserId = entry.key;
        final messages = entry.value;
        
        // Sort messages by timestamp (newest first)
        messages.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
        
        if (messages.isEmpty) continue;
        
        // Get the other user's information
        final otherUser = await AppwriteService.getUserById(otherUserId);
        if (otherUser == null) continue;
        
        final lastMessage = messages.first;
        
        conversationPreviews.add(ConversationPreview(
          conversationId: lastMessage.conversationId ?? '',
          otherUserId: otherUserId,
          otherUserName: otherUser.name,
          otherUserAvatar: otherUser.avatarUrl ?? '',
          lastMessage: lastMessage.content,
          lastMessageTime: DateTime.parse(lastMessage.createdAt),
          isLastMessageFromMe: lastMessage.senderId == _currentUserId,
        ));
      }
      
      // Sort conversations by last message time (newest first)
      conversationPreviews.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      setState(() {
        _conversations = conversationPreviews;
        _filteredConversations = conversationPreviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conversations: $e')),
        );
      }
    }
  }

  void _filterConversations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations
            .where((conversation) => 
                conversation.otherUserName.toLowerCase().contains(query.toLowerCase()) ||
                conversation.lastMessage.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _navigateToChat(ConversationPreview conversation) async {
    if (_currentUserId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          targetUserId: conversation.otherUserId,
          targetUserName: conversation.otherUserName,
        ),
      ),
    );
  }

  Widget _buildConversationTile(ConversationPreview conversation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          backgroundImage: conversation.otherUserAvatar.isNotEmpty 
              ? NetworkImage(conversation.otherUserAvatar)
              : null,
          child: conversation.otherUserAvatar.isEmpty
              ? Text(
                  conversation.otherUserName.isNotEmpty ? conversation.otherUserName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                )
              : null,
        ),
        title: Text(
          conversation.otherUserName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            if (conversation.isLastMessageFromMe) ...[
              Icon(
                Icons.done_all,
                size: 16,
                color: Colors.blue.shade400,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                conversation.lastMessage,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatMessageTime(conversation.lastMessageTime),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              Icons.chat_bubble_outline,
              size: 18,
              color: Colors.blue.shade400,
            ),
          ],
        ),
        onTap: () => _navigateToChat(conversation),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBackBar(
            title: 'Messages',
            backIcon: 'assets/icons/ic_arrow_back.svg',
            actionIcon: 'assets/icons/ic_shield_check.svg',
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterConversations,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'No conversations yet\nStart a conversation by searching for users!'
                                  : 'No conversations match your search',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadConversations,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView.builder(
                          itemCount: _filteredConversations.length,
                          itemBuilder: (context, index) {
                            return _buildConversationTile(_filteredConversations[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserListScreen(),
              ),
            );
          },
          backgroundColor: AppColors.purple,
          child: const Icon(
            Icons.people,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
