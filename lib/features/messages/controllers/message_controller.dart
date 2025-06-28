import 'package:flutter/foundation.dart';
import 'package:belang/services/appwrite_service.dart';
import 'package:belang/data/models/message.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:async';

class MessageController extends ChangeNotifier {
  static final MessageController _instance = MessageController._internal();
  factory MessageController() => _instance;
  MessageController._internal();

  StreamSubscription? _messageSubscription;
  String? _currentUserId;
  
  Map<String, int> _unreadCounts = {}; // userId -> unread count
  Map<String, List<Message>> _conversations = {}; // userId -> messages
  
  // Getters
  Map<String, int> get unreadCounts => _unreadCounts;
  Map<String, List<Message>> get conversations => _conversations;
  
  /// Initialize the controller with current user
  Future<void> initialize() async {
    try {
      final user = await AppwriteService.getCurrentUser();
      _currentUserId = user.$id;
      _setupRealtimeUpdates();
    } catch (e) {
      debugPrint('Failed to initialize MessageController: $e');
    }
  }
  
  /// Setup real-time message updates
  void _setupRealtimeUpdates() {
    if (_currentUserId == null) return;
    
    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('6855dd6b003ce2cab4ff');
    final realtime = Realtime(client);
    
    _messageSubscription = realtime.subscribe([
      'databases.685c69ca0000f9d61a7a.collections.messages.documents',
    ]).stream.listen((event) {
      _handleRealtimeEvent(event);
    });
  }
  
  /// Handle real-time events
  void _handleRealtimeEvent(RealtimeMessage event) {
    if (_currentUserId == null) return;
    
    final data = event.payload;
    final senderId = data['senderId'];
    final receiverId = data['receiverId'];
    
    // Only process messages involving current user
    if (senderId != _currentUserId && receiverId != _currentUserId) {
      return;
    }
    
    if (event.events.any((e) => e.contains('create'))) {
      _handleNewMessage(data);
    } else if (event.events.any((e) => e.contains('update'))) {
      _handleMessageUpdate(data);
    }
  }
  
  /// Handle new message creation
  void _handleNewMessage(Map<String, dynamic> data) {
    final message = Message.fromMap(data);
    
    // Determine the other user in the conversation
    final otherUserId = message.senderId == _currentUserId 
        ? message.receiverId 
        : message.senderId;
    
    // Update conversations
    if (!_conversations.containsKey(otherUserId)) {
      _conversations[otherUserId] = [];
    }
    _conversations[otherUserId]!.insert(0, message);
    
    // Update unread count if message is from other user
    if (message.senderId != _currentUserId) {
      _unreadCounts[otherUserId] = (_unreadCounts[otherUserId] ?? 0) + 1;
    }
    
    notifyListeners();
  }
  
  /// Handle message updates (like read status)
  void _handleMessageUpdate(Map<String, dynamic> data) {
    final message = Message.fromMap(data);
    
    // Determine the other user in the conversation
    final otherUserId = message.senderId == _currentUserId 
        ? message.receiverId 
        : message.senderId;
    
    // Update message in conversation
    if (_conversations.containsKey(otherUserId)) {
      final messages = _conversations[otherUserId]!;
      final index = messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        messages[index] = message;
      }
    }
    
    // Recalculate unread count for this conversation
    _updateUnreadCount(otherUserId);
    
    notifyListeners();
  }
  
  /// Update unread count for a specific user
  Future<void> _updateUnreadCount(String otherUserId) async {
    if (_currentUserId == null) return;
    
    try {
      final count = await AppwriteService.getUnreadMessageCount(
        currentUserId: _currentUserId!,
        otherUserId: otherUserId,
      );
      _unreadCounts[otherUserId] = count;
    } catch (e) {
      debugPrint('Failed to update unread count: $e');
    }
  }
  
  /// Mark messages as read and update counts
  Future<void> markMessagesAsRead(String otherUserId) async {
    if (_currentUserId == null) return;
    
    try {
      await AppwriteService.markMessagesAsRead(
        currentUserId: _currentUserId!,
        otherUserId: otherUserId,
      );
      
      // Update local state
      _unreadCounts[otherUserId] = 0;
      
      // Update messages in conversation
      if (_conversations.containsKey(otherUserId)) {
        for (var message in _conversations[otherUserId]!) {
          if (message.receiverId == _currentUserId) {
            // Create updated message with read status
            // Note: This is a simplified approach - in production you might want
            // to update the actual message objects
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark messages as read: $e');
    }
  }
  
  /// Get unread count for specific user
  int getUnreadCount(String userId) {
    return _unreadCounts[userId] ?? 0;
  }
  
  /// Dispose resources
  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
