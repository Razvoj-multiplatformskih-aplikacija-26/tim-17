import 'dart:ui';

import 'package:flutter/material.dart';

import '../jobly_colors.dart';

class Frosted extends StatelessWidget {
  const Frosted({super.key, required this.child, this.top = false, this.bottom = false});

  final Widget child;

  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    final jobly = Theme.of(context).jobly;
    final line = BorderSide(color: jobly.separator, width: 0.5);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24, tileMode: TileMode.clamp),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: jobly.bar,
            border: Border(top: top ? line : BorderSide.none, bottom: bottom ? line : BorderSide.none),
          ),
          child: child,
        ),
      ),
    );
  }
}
