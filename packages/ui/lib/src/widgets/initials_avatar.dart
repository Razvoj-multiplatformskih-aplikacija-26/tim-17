import 'package:flutter/material.dart';

import '../jobly_colors.dart';
import '../text/serbian.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).jobly.gradient.colors;
    final shift = name.hashCode.abs() % colors.length;
    final rotated = [...colors.sublist(shift), ...colors.sublist(0, shift)];
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: rotated),
        ),
        child: Text(
          initialsOf(name),
          style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.w700, height: 1),
        ),
      ),
    );
  }
}
