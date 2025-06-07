import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lango/core/themes/app_colors.dart';
import 'package:lango/core/themes/typography.dart';

class MessagesSearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const MessagesSearchInput({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.stroke,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/ic_search.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTypography.bodyMediumRegular.copyWith(
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Search chat...',
                  hintStyle: AppTypography.bodyMediumRegular.copyWith(
                    color: AppColors.description,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            SvgPicture.asset(
              'assets/icons/ic_mic.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
