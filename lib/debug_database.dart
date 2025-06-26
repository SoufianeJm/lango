import 'package:belang/services/appwrite_service.dart';

/// Run this function to debug your database structure
/// This will help identify what attributes exist in your users collection
Future<void> debugDatabase() async {
  try {
    print('🔍 Debugging Appwrite Database Structure...\n');
    
    // Try to get current user
    try {
      final currentUser = await AppwriteService.getCurrentUser();
      print('✅ Current user: ${currentUser.name} (${currentUser.$id})');
    } catch (e) {
      print('❌ Not logged in or user error: $e');
    }
    
    print('\n📋 Attempting to fetch users from collection...');
    
    try {
      final users = await AppwriteService.getAllUsers();
      print('✅ Found ${users.length} users in the collection');
      
      if (users.isNotEmpty) {
        print('\n👤 Sample user data:');
        final firstUser = users.first;
        print('- ID: ${firstUser.id}');
        print('- Name: ${firstUser.name}');
        print('- Email: ${firstUser.email}');
        print('- Avatar URL: ${firstUser.avatarUrl ?? "Not set"}');
        print('- Is Online: ${firstUser.isOnline ?? "Not set"}');
        print('- Last Seen: ${firstUser.lastSeen ?? "Not set"}');
        print('- Created At: ${firstUser.createdAt ?? "Not set"}');
      } else {
        print('📝 No users found in the collection.');
        print('   This suggests you need to register a user first.');
      }
      
    } catch (e) {
      print('❌ Error fetching users: $e');
      print('\n🔧 This could mean:');
      print('1. The "users" collection doesn\'t exist');
      print('2. The collection has different attribute names');
      print('3. Permission issues');
      print('4. Database ID is incorrect');
      
      print('\n📋 Current configuration:');
      print('- Database ID: ${AppwriteService.databaseId}');
      print('- Users Collection ID: ${AppwriteService.usersCollectionId}');
    }
    
  } catch (e) {
    print('💥 Major error: $e');
  }
}

/// Call this function from your app to debug
/// You can add this to a debug screen or call it temporarily
void main() async {
  await debugDatabase();
}
