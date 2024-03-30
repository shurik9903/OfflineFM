import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatefulWidget {
  const GlassContainer(
      {super.key,
      this.width,
      this.height,
      required this.child,
      this.color = Colors.white});

  final double? width;
  final double? height;
  final Widget child;
  final Color color;

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 4.0,
                sigmaY: 4.0,
              ),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.color.withOpacity(0.13)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withOpacity(0.15),
                    widget.color.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            Center(
              child: widget.child,
            )
          ],
        ),
      ),
    );
  }
}
