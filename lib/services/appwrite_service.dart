import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteService {
  static final Client _client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // Update if using self-hosted
    ..setProject('6855dd6b003ce2cab4ff'); // Your Project ID

  static final Account _account = Account(_client);

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
}
