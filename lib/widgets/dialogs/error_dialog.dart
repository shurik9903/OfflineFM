import 'package:flutter/material.dart';

Future<void> showErrorDialog(
    BuildContext context, String title, String error) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(error),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, null),
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
