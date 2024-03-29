import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final int emotion;
  final String text;

  final void Function()? onTap;

  const UserTile(
      {super.key,
      required this.emotion,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 40,
        ),
        child: Row(
          children: [
            // icon
            SizedBox(
              height: 40,
              width: 40,
              child: Image.asset('images/chat_icon_$emotion.png'),
            ),
            const SizedBox(
              width: 20,
            ),
            // user name
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
