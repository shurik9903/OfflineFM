import 'package:flutter/material.dart';

Future<bool> showAlertDialog(BuildContext context, String text,
    String cancelButton, String okButton) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удалить радио'),
      content: Text(text),
      actions: [
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            okButton,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => Navigator.pop(context, false),
          child:
              Text(cancelButton, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
