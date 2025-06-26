// This file was moved from starter-for-flutter/lib/data/repository/appwrite_repository.dart
// to lib/data/repository/appwrite_repository.dart to fix import issues.

import 'package:intl/intl.dart';
import 'package:appwrite/appwrite.dart';
import 'package:belang/constants/appwrite.dart';
import 'package:belang/data/models/log.dart';
import 'package:belang/data/models/project_info.dart';
import 'package:belang/data/models/message.dart';

/// A repository responsible for handling network interactions with the Appwrite server.
///
/// It provides a helper method to ping the server.
class AppwriteRepository {
  static const String pingPath = "/ping";
  static const String appwriteProjectId = AppwriteConstants.APPWRITE_PROJECT_ID;
  static const String appwriteProjectName = AppwriteConstants.APPWRITE_PROJECT_NAME;
  static const String appwritePublicEndpoint = AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT;

  // TODO: Replace with your actual database ID from Appwrite Console
  static const String databaseId = '685c69ca0000f9d61a7a';
  static const String messagesCollectionId = 'messages';

  final Client _client = Client()
      .setProject(appwriteProjectId)
      .setEndpoint(appwritePublicEndpoint);

  late final Account _account;
  late final Databases _databases;

  // Public getters
  Account get account => _account;
  Client get client => _client;


  AppwriteRepository._internal() {
    _account = Account(_client);
    _databases = Databases(_client);
  }

  static final AppwriteRepository _instance = AppwriteRepository._internal();

  /// Singleton instance getter
  factory AppwriteRepository() => _instance;

  ProjectInfo getProjectInfo() {
    return ProjectInfo(
      endpoint: appwritePublicEndpoint,
      projectId: appwriteProjectId,
      projectName: appwriteProjectName,
    );
  }

  /// Pings the Appwrite server and captures the response.
  ///
  /// @return [Log] containing request and response details.
  Future<Log> ping() async {
    try {
      final response = await _client.ping();

      return Log(
        date: _getCurrentDate(),
        status: 200,
        method: "GET",
        path: pingPath,
        response: response,
      );
    } on AppwriteException catch (error) {
      return Log(
        date: _getCurrentDate(),
        status: error.code ?? 500,
        method: "GET",
        path: pingPath,
        response: error.message ?? "Unknown error",
      );
    }
  }

  /// Retrieves the current date in the format "MMM dd, HH:mm".
  ///
  /// @return [String] A formatted date.
  String _getCurrentDate() {
    return DateFormat("MMM dd, HH:mm").format(DateTime.now());
  }

  /// Registers a new user with email and password using Appwrite.
  Future<dynamic> register({required String email, required String password}) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return user; // This returns a User object, so type is dynamic
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  /// Sends a message to the messages collection
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: messagesCollectionId,
        documentId: ID.unique(),
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to send message');
    }
  }

  /// Fetches messages between two users (both directions)
  Future<List<Message>> getMessagesBetweenUsers({
    required String userA,
    required String userB,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: messagesCollectionId,
        queries: [
          Query.or([
            Query.and([
              Query.equal('senderId', userA),
              Query.equal('receiverId', userB),
            ]),
            Query.and([
              Query.equal('senderId', userB),
              Query.equal('receiverId', userA),
            ]),
          ]),
        ],
      );
      return result.documents.map((doc) => Message.fromMap(doc.data..['\$id'] = doc.data['\$id'])).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch messages');
    }
  }

  /// Logs in a user with email and password using Appwrite.
  Future<dynamic> login({required String email, required String password}) async {
    try {
      // Appwrite v14.x does not support createEmailSession. Use createSession or the correct login method as per your backend setup.
// For email/password login, you may need to use Appwrite's authentication API directly or update your SDK version.
// Example placeholder (update with your actual login logic):
final session = await _account.createSession(
  userId: email, // This may need to be changed based on your Appwrite setup
  secret: password, // This may need to be changed based on your Appwrite setup
);

      return session;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }
}
