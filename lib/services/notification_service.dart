import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:appwrite/appwrite.dart';
import 'package:belang/services/appwrite_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RealtimeMessage>? _messageSubscription;
  String? _currentUserId;

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    await _requestNotificationPermissions();

    // Set up message listener
    await _setupMessageListener();
  }

  Future<void> _requestNotificationPermissions() async {
    final status = await perm.Permission.notification.status;
    if (status.isDenied) {
      await perm.Permission.notification.request();
    }
  }

  Future<void> _setupMessageListener() async {
    try {
      // Get current user ID
      final user = await AppwriteService.getCurrentUser();
      _currentUserId = user.$id;

      // Create realtime client
      final client = Client()
          .setEndpoint('https://cloud.appwrite.io/v1')
          .setProject('6855dd6b003ce2cab4ff');
      final realtime = Realtime(client);

      // Subscribe to message events
      _messageSubscription = realtime.subscribe([
        'databases.685c69ca0000f9d61a7a.collections.messages.documents',
      ]).stream.listen((event) {
        if (event.events.contains('databases.*.collections.*.documents.*.create')) {
          _handleNewMessage(event.payload);
        }
      });
    } catch (e) {
      print('Failed to setup message listener: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> messageData) {
    // Only show notification if the current user is the receiver
    if (_currentUserId != null && 
        messageData['receiverId'] == _currentUserId &&
        messageData['senderId'] != _currentUserId) {
      _showMessageNotification(
        senderName: 'New Message', // You can enhance this by fetching sender name
        messageContent: messageData['content'] ?? 'New message received',
        senderId: messageData['senderId'] ?? '',
      );
    }
  }

  Future<void> _showMessageNotification({
    required String senderName,
    required String messageContent,
    required String senderId,
  }) async {
    // Try to get sender's name from database
    try {
      final sender = await AppwriteService.getUserById(senderId);
      senderName = sender?.name ?? senderName;
    } catch (e) {
      // Use default name if can't fetch
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
      senderName,
      messageContent,
      platformChannelSpecifics,
      payload: senderId, // Pass sender ID as payload for when notification is tapped
    );
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap - you can navigate to chat screen here
    final senderId = notificationResponse.payload;
    if (senderId != null) {
      // TODO: Navigate to chat screen with this sender
      print('Notification tapped for sender: $senderId');
    }
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'general',
      'General',
      channelDescription: 'General app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> testNotification() async {
    await showCustomNotification(
      title: 'Test Notification',
      body: 'Notifications are working! 🎉',
    );
  }

  void dispose() {
    _messageSubscription?.cancel();
  }
}
