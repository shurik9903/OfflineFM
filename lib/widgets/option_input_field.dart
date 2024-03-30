import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptionInputField extends StatefulWidget {
  const OptionInputField(
      {super.key, required this.controller, required this.text});

  final String text;
  final TextEditingController controller;

  @override
  State<OptionInputField> createState() => _OptionInputFieldState();
}

class _OptionInputFieldState extends State<OptionInputField> {
  late String text;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text),
        SizedBox(
          width: 35,
          child: TextFormField(
            style: const TextStyle(height: 1, color: Colors.white),
            textAlign: TextAlign.center,
            decoration: const InputDecoration.collapsed(
                hintText: 'Дни',
                hintStyle: TextStyle(height: 2, color: Colors.white),
                filled: true,
                fillColor: Colors.grey),
            cursorColor: Colors.black,
            controller: controller,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3)
            ],
            keyboardType: TextInputType.number,
          ),
        )
      ],
    );
  }
}
