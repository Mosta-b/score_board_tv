import 'package:colorful_background/colorful_background.dart';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ColorfulBackground(
      duration: Duration(milliseconds: 1000),
      backgroundColors: [
        Colors.green,
        Colors.greenAccent,
        Colors.lightGreen,
        Colors.lightGreenAccent,
      ],

      child: child,
    );
  }
}
