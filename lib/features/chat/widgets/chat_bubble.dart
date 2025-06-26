import 'package:flutter/material.dart';
import 'package:belang/core/themes/typography.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
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
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              style: AppTypography.bodyMediumRegular.copyWith(
  color: Colors.white,
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
          child: Text(
            DateFormat('hh:mm a').format(time).replaceAll('AM', 'Am').replaceAll('PM', 'Pm'),
            style: AppTypography.bodyMediumRegular.copyWith(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}