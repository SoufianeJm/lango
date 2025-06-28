import 'package:flutter/material.dart';
import 'package:belang/core/widgets/app_back_bar.dart';
import 'package:belang/features/chat/screens/chat_screen.dart';
import 'package:belang/services/appwrite_service.dart';
import 'package:belang/data/models/user.dart';
import 'package:belang/data/models/message.dart';
import 'package:belang/features/messages/screens/user_list_screen.dart';
import 'package:belang/core/themes/app_colors.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:async';

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
  final int unreadCount;

  ConversationPreview({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isLastMessageFromMe,
    required this.unreadCount,
  });
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  List<ConversationPreview> _conversations = [];
  String? _currentUserId;
  bool _isLoading = true;
  String _searchQuery = '';
  List<ConversationPreview> _filteredConversations = [];
  StreamSubscription? _messageSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _setupRealtimeUpdates();
  }

  Future<void> _loadConversations() async {
    try {
      // Get current user ID
      final currentUser = await AppwriteService.getCurrentUser();
      _currentUserId = currentUser.$id;

      // Get all messages where current user is either sender or receiver
      final allMessages = await AppwriteService.getAllMessagesForUser(
        _currentUserId!,
      );

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
        messages.sort(
          (a, b) => DateTime.parse(
            b.createdAt,
          ).compareTo(DateTime.parse(a.createdAt)),
        );

        if (messages.isEmpty) continue;

        // Get the other user's information
        final otherUser = await AppwriteService.getUserById(otherUserId);
        if (otherUser == null) continue;

        final lastMessage = messages.first;

        // Get unread count for this conversation
        final unreadCount = await AppwriteService.getUnreadMessageCount(
          currentUserId: _currentUserId!,
          otherUserId: otherUserId,
        );

        conversationPreviews.add(
          ConversationPreview(
            conversationId: lastMessage.conversationId ?? '',
            otherUserId: otherUserId,
            otherUserName: otherUser.name,
            otherUserAvatar: otherUser.avatarUrl ?? '',
            lastMessage: lastMessage.content,
            lastMessageTime: DateTime.parse(lastMessage.createdAt),
            isLastMessageFromMe: lastMessage.senderId == _currentUserId,
            unreadCount: unreadCount,
          ),
        );
      }

      // Sort conversations by last message time (newest first)
      conversationPreviews.sort(
        (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
      );

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
            .where(
              (conversation) =>
                  conversation.otherUserName.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  conversation.lastMessage.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupRealtimeUpdates() {
    // Create a realtime client for listening to message updates
    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('6855dd6b003ce2cab4ff');
    final realtime = Realtime(client);
    
    // Listen for message document changes (create, update, delete)
    _messageSubscription = realtime.subscribe([
      'databases.685c69ca0000f9d61a7a.collections.messages.documents',
    ]).stream.listen((event) {
      if (_currentUserId == null) return;
      
      final data = event.payload;
      final senderId = data['senderId'];
      final receiverId = data['receiverId'];
      
      // Only process messages involving current user
      if (senderId != _currentUserId && receiverId != _currentUserId) {
        return;
      }
      
      if (event.events.any((e) => e.contains('databases.*.collections.*.documents.*.update'))) {
        // For updates (like read status changes), update immediately
        _updateConversationReadStatus(senderId, receiverId, data);
      } else if (event.events.any((e) => e.contains('databases.*.collections.*.documents.*.create'))) {
        // For new messages, debounce to avoid excessive calls
        _refreshTimer?.cancel();
        _refreshTimer = Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            _loadConversations();
          }
        });
      }
    });
  }
  
  void _updateConversationReadStatus(String senderId, String receiverId, Map<String, dynamic> data) {
    if (!mounted) return;
    
    // Find the conversation to update
    final otherUserId = senderId == _currentUserId ? receiverId : senderId;
    final conversationIndex = _conversations.indexWhere((conv) => conv.otherUserId == otherUserId);
    
    if (conversationIndex != -1) {
      // Update unread count immediately for this specific conversation
      AppwriteService.getUnreadMessageCount(
        currentUserId: _currentUserId!,
        otherUserId: otherUserId,
      ).then((newUnreadCount) {
        if (mounted) {
          setState(() {
            final updatedConversation = ConversationPreview(
              conversationId: _conversations[conversationIndex].conversationId,
              otherUserId: _conversations[conversationIndex].otherUserId,
              otherUserName: _conversations[conversationIndex].otherUserName,
              otherUserAvatar: _conversations[conversationIndex].otherUserAvatar,
              lastMessage: _conversations[conversationIndex].lastMessage,
              lastMessageTime: _conversations[conversationIndex].lastMessageTime,
              isLastMessageFromMe: _conversations[conversationIndex].isLastMessageFromMe,
              unreadCount: newUnreadCount,
            );
            
            _conversations[conversationIndex] = updatedConversation;
            
            // Update filtered conversations too
            final filteredIndex = _filteredConversations.indexWhere((conv) => conv.otherUserId == otherUserId);
            if (filteredIndex != -1) {
              _filteredConversations[filteredIndex] = updatedConversation;
            }
          });
        }
      }).catchError((e) {
        print('Failed to update unread count: $e');
      });
    }
  }

  Future<void> _navigateToChat(ConversationPreview conversation) async {
    if (_currentUserId == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          targetUserId: conversation.otherUserId,
          targetUserName: conversation.otherUserName,
        ),
      ),
    );
    
    // Refresh conversations when returning from chat to update read status
    if (result == null || result == true) {
      _loadConversations();
    }
  }

  Widget _buildConversationTile(ConversationPreview conversation) {
    // Mock data for demonstration - you can replace with real data
    final bool isOnline = true; // Replace with actual online status
    final int unreadCount = conversation.unreadCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToChat(conversation),
        child: Row(
          children: [
            // Avatar with online status
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: conversation.otherUserAvatar.isNotEmpty
                      ? NetworkImage(conversation.otherUserAvatar)
                      : null,
                  child: conversation.otherUserAvatar.isEmpty
                      ? Text(
                          conversation.otherUserName.isNotEmpty
                              ? conversation.otherUserName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.grey.shade700,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    conversation.otherUserName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Last message with status
                  Row(
                    children: [
                      if (conversation.isLastMessageFromMe) ...[
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: const TextStyle(
                            color: AppColors.description,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatMessageTime(conversation.lastMessageTime),
                  style: const TextStyle(
                    color: AppColors.description,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                if (unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate.isAtSameMomentAs(today)) {
      // Today - show time in HH:MM AM/PM format
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[time.weekday - 1];
    } else {
      // Older - show date
      return '${time.day}/${time.month}/${time.year}';
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
                    child: ListView.separated(
                      itemCount: _filteredConversations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox.shrink(),
                      itemBuilder: (context, index) {
                        return _buildConversationTile(
                          _filteredConversations[index],
                        );
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
              MaterialPageRoute(builder: (context) => const UserListScreen()),
            );
          },
          backgroundColor: AppColors.black,
          child: const Icon(Icons.people, color: Colors.white),
        ),
      ),
    );
  }
}
