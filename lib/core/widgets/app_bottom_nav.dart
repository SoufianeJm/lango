import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:belang/core/themes/app_colors.dart';
import 'package:belang/core/themes/typography.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navItems = [
      _NavItem(
        icon: 'assets/icons/ic_nav_home.svg',
        activeIcon: 'assets/icons/ic_nav_home_filled.svg',
        label: 'Home',
      ),
      _NavItem(
        icon: 'assets/icons/ic_nav_search.svg',
        activeIcon: 'assets/icons/ic_nav_search_filled.svg',
        label: 'Search',
      ),
      _NavItem(
        icon: 'assets/icons/ic_nav_discover.svg',
        activeIcon: 'assets/icons/ic_nav_discover_filled.svg',
        label: 'Discover',
      ),
      _NavItem(
        icon: 'assets/icons/ic_nav_chat.svg',
        activeIcon: 'assets/icons/ic_nav_chat_filled.svg',
        label: 'Chat',
      ),
      _NavItem(
        icon: 'assets/icons/ic_nav_profile.svg',
        activeIcon: 'assets/icons/ic_nav_profile_filled.svg',
        label: 'Profile',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isActive = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap?.call(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  isActive ? item.activeIcon : item.icon,
                  width: 24,
                  height: 24,
                  // Only apply colorFilter to inactive icons
                  colorFilter: isActive ? null : ColorFilter.mode(AppColors.description, BlendMode.srcIn),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: AppTypography.bodySmallRegular.copyWith(
                    color: isActive ? AppColors.black : AppColors.description,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
