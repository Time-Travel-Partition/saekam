import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final int emotion;
  final bool isCurrentUser;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.emotion,
      required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            SizedBox(
              height: 40,
              width: 40,
              child: Image.asset('images/chat_icon_$emotion.png'),
            ),
          Container(
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.blue),
            ),
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.only(
              top: isCurrentUser ? 10 : 5,
            ),
            child: Text(
              message,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
