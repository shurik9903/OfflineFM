import 'dart:typed_data';

import 'package:flutter/material.dart';

class HeaderRadioContainer extends StatefulWidget {
  const HeaderRadioContainer(
      {super.key, required this.group, required this.name, this.image});

  final String group;
  final String name;
  final Uint8List? image;

  @override
  State<HeaderRadioContainer> createState() => _HeaderRadioContainerState();
}

class _HeaderRadioContainerState extends State<HeaderRadioContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 75),
          child: widget.image == null
              ? Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: const FittedBox(
                    child: Icon(
                      Icons.radio,
                      color: Colors.black,
                    ),
                  ),
                )
              : Image(
                  image: MemoryImage(widget.image!),
                  fit: BoxFit.cover,
                ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.group,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ],
    );
  }
}
