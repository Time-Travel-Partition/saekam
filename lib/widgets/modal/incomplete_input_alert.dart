import 'package:flutter/material.dart';

class IncompleteInputAlert extends StatelessWidget {
  final String message;

  const IncompleteInputAlert({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      content: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          elevation: const MaterialStatePropertyAll(0),
        ),
        child: const Text(
          '확인',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}