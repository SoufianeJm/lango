import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lango/core/themes/typography.dart';
import 'package:lango/core/themes/app_colors.dart';


class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.stroke,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/emoji.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTypography.bodyMediumRegular.copyWith(
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Type your message...',
                  hintStyle: AppTypography.bodyMediumRegular.copyWith(
                    color: AppColors.description,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/send.svg',
                width: 24,
                height: 24,
              ),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}