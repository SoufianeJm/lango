import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'dart:io';
import 'package:belang/data/models/user.dart';
import 'package:belang/data/models/message.dart';

class AppwriteService {
  static const String profilePicsBucketId = 'profile-pics'; // You must create this bucket in Appwrite
  static const String databaseId = '685c69ca0000f9d61a7a';
  static const String usersCollectionId = 'users';
  static const String messagesCollectionId = 'messages';
  static const String conversationsCollectionId = 'conversations';

  static final Client _client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // Update if using self-hosted
    ..setProject('6855dd6b003ce2cab4ff'); // Your Project ID

  static final Account _account = Account(_client);
  static final Storage _storage = Storage(_client);
  static final Databases _databases = Databases(_client);

  /// Register a new user with email and password
  static Future<models.User> register({required String email, required String password, required String name}) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return user;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  /// Login a user with email and password (Appwrite v14+)
  static Future<models.Session> login({required String email, required String password}) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  /// Logout current session
  static Future<void> logout({required String sessionId}) async {
    try {
      await _account.deleteSession(sessionId: sessionId);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Logout failed');
    }
  }

  /// Get current logged in user
  static Future<models.User> getCurrentUser() async {
    try {
      final user = await _account.get();
      return user;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Could not get user');
    }
  }

  /// Update user name
  static Future<void> updateName(String name) async {
    try {
      await _account.updateName(name: name);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Could not update name');
    }
  }

  /// Update user email (requires password for security)
  static Future<void> updateEmail(String email, String password) async {
    try {
      await _account.updateEmail(email: email, password: password);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Could not update email');
    }
  }

  /// Update user password
  static Future<void> updatePassword(String password) async {
    try {
      await _account.updatePassword(password: password);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Could not update password');
    }
  }

  /// Update user prefs (e.g. store photoUrl)
  static Future<void> updateUserPrefs(Map<String, dynamic> prefs) async {
    try {
      await _account.updatePrefs(prefs: prefs);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Could not update user preferences');
    }
  }

  /// Upload profile image to Appwrite Storage and return file URL
  static Future<String> uploadProfileImage(File file, String userId) async {
    try {
      final fileId = ID.unique();
      final result = await _storage.createFile(
        bucketId: profilePicsBucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: file.path),
      );
      // Generate a public URL for the file
      final url = 'https://cloud.appwrite.io/v1/storage/buckets/$profilePicsBucketId/files/${result.$id}/view?project=6855dd6b003ce2cab4ff&mode=admin';
      return url;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Could not upload profile image');
    }
  }

  /// Create user document in custom users collection after registration
  static Future<void> createUserDocument({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    try {
      // Only create with fields that exist in your database structure
      final userData = {
        'name': name,
        'email': email,
        'lastSeen': DateTime.now().toIso8601String(),
      };
      
      // Only add avatarUrl if it's provided and not empty
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        userData['avatarUrl'] = avatarUrl;
      }
      
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: userData,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to create user document');
    }
  }

  /// Update user document in the custom users collection
  static Future<void> updateUserDocument({
    required String userId,
    String? name,
    String? avatarUrl,
    bool? isOnline,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
      if (isOnline != null) updateData['isOnline'] = isOnline;
      updateData['lastSeen'] = DateTime.now().toIso8601String();

      await _databases.updateDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: updateData,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to update user document');
    }
  }

  /// Get all users from the custom users collection
  static Future<List<AppUser>> getAllUsers() async {
    try {
      final result = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'), // Use system createdAt field
        ],
      );

      return result.documents.map((doc) {
        final data = doc.data;
        data['\$id'] = doc.$id;
        data['\$createdAt'] = doc.$createdAt;
        return AppUser.fromMap(data);
      }).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch users');
    }
  }

  /// Get a specific user by ID
  static Future<AppUser?> getUserById(String userId) async {
    try {
      final result = await _databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );
      return AppUser.fromMap(result.data);
    } on AppwriteException catch (e) {
      // Return null if user not found instead of throwing exception
      return null;
    }
  }

  /// Create a new conversation between two users
  static Future<String> createConversation({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      final conversationId = ID.unique();
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: conversationsCollectionId,
        documentId: conversationId,
        data: {
          'participants': [user1Id, user2Id],
          'lastMessage': '',
          'lastMessageTime': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      return conversationId;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to create conversation');
    }
  }

  /// Get conversation between two users (if exists)
  static Future<String?> getConversationId({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: conversationsCollectionId,
        queries: [
          Query.or([
            Query.and([
              Query.contains('participants', user1Id),
              Query.contains('participants', user2Id),
            ]),
          ]),
        ],
      );

      if (result.documents.isNotEmpty) {
        return result.documents.first.$id;
      }
      return null;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to get conversation');
    }
  }

  /// Send a message (simplified version without conversations)
  static Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? conversationId, // Keep for compatibility but not used for now
  }) async {
    try {
      // Send the message directly without conversation management
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: messagesCollectionId,
        documentId: ID.unique(),
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to send message');
    }
  }

  /// Get messages between two users
  static Future<List<Message>> getMessagesBetweenUsers({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: messagesCollectionId,
        queries: [
          Query.or([
            Query.and([
              Query.equal('senderId', user1Id),
              Query.equal('receiverId', user2Id),
            ]),
            Query.and([
              Query.equal('senderId', user2Id),
              Query.equal('receiverId', user1Id),
            ]),
          ]),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return result.documents.map((doc) {
        final data = doc.data;
        data['\$id'] = doc.$id;
        data['\$createdAt'] = doc.$createdAt;
        return Message.fromMap(data);
      }).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch messages');
    }
  }

  /// Get all messages for a user (where they are sender or receiver)
  static Future<List<Message>> getAllMessagesForUser(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: messagesCollectionId,
        queries: [
          Query.or([
            Query.equal('senderId', userId),
            Query.equal('receiverId', userId),
          ]),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return result.documents.map((doc) {
        final data = doc.data;
        data['\$id'] = doc.$id;
        data['\$createdAt'] = doc.$createdAt;
        return Message.fromMap(data);
      }).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch messages');
    }
  }

  /// Get all conversations for a user (kept for compatibility but not used)
  static Future<List<Map<String, dynamic>>> getUserConversations(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: conversationsCollectionId,
        queries: [
          Query.contains('participants', userId),
          Query.orderDesc('lastMessageTime'),
        ],
      );

      return result.documents.map((doc) {
        final data = doc.data;
        data['\$id'] = doc.$id;
        return data;
      }).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch conversations');
    }
  }
}


