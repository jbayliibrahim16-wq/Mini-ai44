import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const MessageBubble({
    Key? key,
    required this.content,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.grey[200],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
