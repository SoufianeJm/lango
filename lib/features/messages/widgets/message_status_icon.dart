import 'package:flutter/material.dart';
import 'package:belang/core/themes/app_colors.dart';

class MessageStatusIcon extends StatelessWidget {
  final bool isRead;
  final bool isFromMe;
  final bool isDelivered;

  const MessageStatusIcon({
    Key? key,
    required this.isRead,
    required this.isFromMe,
    this.isDelivered = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isFromMe) {
      // Don't show status icons for received messages
      return const SizedBox.shrink();
    }

    return Icon(
      isRead ? Icons.done_all : Icons.done,
      size: 16,
      color: isRead ? AppColors.success : AppColors.description,
    );
  }
}
