import 'package:flutter/material.dart';
import 'package:belang/services/appwrite_service.dart';
import 'package:belang/features/auth/login/screens/login-screen.dart';
import 'edit_profile_screen.dart';

import 'package:belang/core/themes/app_colors.dart';
import 'package:belang/core/themes/typography.dart';
import 'package:appwrite/models.dart' as models;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<models.User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AppwriteService.getCurrentUser();
  }

  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FutureBuilder<models.User>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Could not load user info',
                          style: AppTypography.bodyMediumRegular.copyWith(color: AppColors.error),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: AppColors.grey100,
                              backgroundImage: (user.prefs.data != null && user.prefs.data['photoUrl'] != null && user.prefs.data['photoUrl'].toString().isNotEmpty)
                                  ? NetworkImage(user.prefs.data['photoUrl'])
                                  : null,
                              child: (user.prefs.data == null || user.prefs.data['photoUrl'] == null || user.prefs.data['photoUrl'].toString().isEmpty)
                                  ? Icon(Icons.account_circle, size: 80, color: AppColors.black)
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              user.name ?? '-',
                              style: AppTypography.h1Medium.copyWith(color: AppColors.black),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.email ?? '-',
                              style: AppTypography.bodyMediumRegular.copyWith(color: AppColors.description),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(user: user),
                                  ),
                                );
                                if (context.mounted) {
                                  setState(() {
                                    _isRefreshing = true;
                                  });
                                  final future = AppwriteService.getCurrentUser();
                                  setState(() {
                                    _userFuture = future;
                                  });
                                  await future;
                                  if (mounted) {
                                    setState(() {
                                      _isRefreshing = false;
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Edit Profile'),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () async {
                                await AppwriteService.logout(sessionId: 'current');
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                              child: const Text('Logout', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
          if (_isRefreshing)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
