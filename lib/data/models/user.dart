class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool? isOnline;
  final String? lastSeen;
  final String? createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isOnline,
    this.lastSeen,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: _getAvatarUrl(map),
      isOnline: map['isOnline'], // This field doesn't exist in your DB, will be null
      lastSeen: map['lastSeen'],
      createdAt: map['createdAt'] ?? map['\$createdAt'], // Use system createdAt if custom doesn't exist
    );
  }

  static String? _getAvatarUrl(Map<String, dynamic> map) {
    // Try different possible field names for avatar URL
    final possibleFields = ['avatarUrl', 'avatarurl', 'avatar_url', 'profilePicture', 'profilePictureUrl'];
    for (final field in possibleFields) {
      final value = map[field];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl ?? '',
      'isOnline': isOnline ?? false,
      'lastSeen': lastSeen ?? DateTime.now().toIso8601String(),
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
} 
