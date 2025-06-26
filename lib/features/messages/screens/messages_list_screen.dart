import 'package:flutter/material.dart';
import 'package:belang/core/widgets/app_back_bar.dart';
import 'package:belang/features/chat/screens/chat_screen.dart';
import 'package:belang/services/appwrite_service.dart';
import 'package:belang/data/models/user.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  List<AppUser> _users = [];
  String? _currentUserId;
  bool _isLoading = true;
  String _searchQuery = '';
  List<AppUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsersAndCurrentUser();
  }

  Future<void> _loadUsersAndCurrentUser() async {
    try {
      // Get current user ID
      final currentUser = await AppwriteService.getCurrentUser();
      _currentUserId = currentUser.$id;

      // Get all users from the custom users collection
      final allUsers = await AppwriteService.getAllUsers();
      
      // Filter out the current user
      final otherUsers = allUsers.where((user) => user.id != _currentUserId).toList();
      
      setState(() {
        _users = otherUsers;
        _filteredUsers = otherUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users
            .where((user) => 
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _navigateToChat(AppUser targetUser) async {
    if (_currentUserId == null) return;

    // Navigate directly to chat screen - no need to check conversations for now
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          targetUserId: targetUser.id,
          targetUserName: targetUser.name,
        ),
      ),
    );
  }

  Widget _buildUserTile(AppUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          backgroundImage: user.avatarUrl?.isNotEmpty == true 
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl?.isEmpty != false
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chat_bubble_outline,
          color: Colors.blue.shade400,
        ),
        onTap: () => _navigateToChat(user),
      ),
    );
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
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'No users found\nCheck back later for new people to chat with!'
                                  : 'No users match your search',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadUsersAndCurrentUser,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsersAndCurrentUser,
                        child: ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            return _buildUserTile(_filteredUsers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
