import 'package:flutter/material.dart';

class Option extends StatefulWidget {
  const Option({
    super.key,
    required this.title,
    required this.options,
  });

  final String title;
  final List<Widget> options;

  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.options,
              ],
            ),
          )
        ],
      ),
    );
  }
}
