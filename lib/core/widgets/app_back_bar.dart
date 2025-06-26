import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:belang/core/themes/app_colors.dart';
import 'package:belang/core/themes/typography.dart';

class AppBackBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAction;
  final String? actionIcon; 
  final String backIcon;    

  const AppBackBar({
    super.key,
    required this.title,
    this.onBack,
    this.onAction,
    this.actionIcon,
    required this.backIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey400.withOpacity(0.3)),
                ),
                child: SvgPicture.asset(
                  backIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Title (auto-expands)
            Expanded(
              child: Text(
                title,
                style: AppTypography.h6SemiBold.copyWith(
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 12),

            // Optional Right-side Action Icon
            if (actionIcon != null)
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grey400.withOpacity(0.3)),
                  ),
                  child: SvgPicture.asset(
                    actionIcon!,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
