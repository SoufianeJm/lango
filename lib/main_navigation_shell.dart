import 'package:flutter/material.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'features/messages/screens/messages_list_screen.dart';
import 'features/profile/screens/profile-screen.dart';
import 'core/themes/app_colors.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 3; // Default to Messages tab

  final List<Widget> _screens = const [
    Center(child: Text('Home')), // TODO: Replace with HomeScreen
    Center(child: Text('Search')), // TODO: Replace with SearchScreen
    Center(child: Text('Discover')), // TODO: Replace with DiscoverScreen
    MessagesListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
