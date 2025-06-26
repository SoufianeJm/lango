import 'package:flutter/material.dart';
import 'features/auth/register/screens/register-screen.dart';
import 'features/auth/login/screens/login-screen.dart';
import 'services/appwrite_service.dart';
import 'main_navigation_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: AppwriteService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // Not logged in or error: show login
            return const LoginScreen();
          } else if (snapshot.hasData) {
            // Logged in: show main app
            return const MainNavigationShell();
          } else {
            // Fallback
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
