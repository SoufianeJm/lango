import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'dart:io';

class AppwriteService {
  static const String profilePicsBucketId = 'profile-pics'; // You must create this bucket in Appwrite

  static final Client _client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // Update if using self-hosted
    ..setProject('6855dd6b003ce2cab4ff'); // Your Project ID

  static final Account _account = Account(_client);
  static final Storage _storage = Storage(_client);

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
}


