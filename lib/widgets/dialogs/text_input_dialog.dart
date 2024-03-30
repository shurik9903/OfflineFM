import 'package:flutter/material.dart';

Future<String?> showTextInputDialog(BuildContext context,
    {String? text}) async {
  return showDialog(
      context: context,
      builder: (context) {
        TextEditingController textEditingController =
            TextEditingController(text: text);

        return AlertDialog(
          title: const Text('Редактировать имя'),
          content: TextField(
            onChanged: (value) {},
            controller: textEditingController,
            decoration: const InputDecoration(hintText: "Введите имя"),
          ),
          actions: [
            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              child: const Text('Изменит'),
              onPressed: () {
                Navigator.pop(context, textEditingController.text);
              },
            ),
          ],
        );
      });
}
