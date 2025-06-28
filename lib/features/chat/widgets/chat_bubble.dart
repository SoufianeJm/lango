import 'package:flutter/material.dart';
import 'package:belang/core/themes/typography.dart';
import 'package:belang/core/themes/app_colors.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;
  final bool? isRead; // Optional read status for sent messages

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    this.isRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: isMe ? Colors.black : AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              style: AppTypography.bodyMediumRegular.copyWith(
                color: isMe ? Colors.white : Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: isMe ? 0 : 16,
            right: isMe ? 16 : 0,
            bottom: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('hh:mm a').format(time).replaceAll('AM', 'Am').replaceAll('PM', 'Pm'),
                style: AppTypography.bodyMediumRegular.copyWith(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // Show read receipt for sent messages
              if (isMe && isRead != null) ...[
                const SizedBox(width: 4),
                Icon(
                  isRead! ? Icons.done_all : Icons.done,
                  size: 16,
                  color: isRead! ? Colors.blue : Colors.grey[600],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}