import 'package:flutter/material.dart';

import '../jobly_colors.dart';

class GradientMask extends StatelessWidget {
  const GradientMask({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).jobly.gradient;
    final middle = gradient.colors[gradient.colors.length ~/ 2];
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          gradient.createShader(Offset.zero & bounds.size),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: middle),
        child: IconTheme.merge(
          data: IconThemeData(color: middle),
          child: child,
        ),
      ),
    );
  }
}

class JoblyWordmark extends StatelessWidget {
  const JoblyWordmark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Jobly',
      child: ExcludeSemantics(
        child: GradientMask(
          child: Text(
            'jobly',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
