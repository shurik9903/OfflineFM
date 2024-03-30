import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MarqueeText extends StatefulWidget {
  const MarqueeText({super.key, required this.text, this.color = Colors.white});

  final String text;
  final Color color;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        TextSpan span = TextSpan(
          text: widget.text,
          style: const TextStyle(fontSize: 18),
        );

        TextPainter tp = TextPainter(
          maxLines: 1,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          text: span,
        );

        tp.layout(maxWidth: constraints.maxWidth);

        bool exceeded = tp.didExceedMaxLines;

        TextStyle style = TextStyle(
          fontSize: 18,
          color: widget.color,
          fontWeight: FontWeight.bold,
        );

        return exceeded
            ? Marquee(
                text: widget.text,
                pauseAfterRound: const Duration(seconds: 5),
                blankSpace: 25,
                style: style,
              )
            : FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  widget.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              );
      },
    );
  }
}
