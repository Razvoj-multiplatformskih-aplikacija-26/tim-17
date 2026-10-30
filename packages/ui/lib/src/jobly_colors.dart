import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

@immutable
class JoblyColors extends ThemeExtension<JoblyColors> {
  const JoblyColors({
    required this.gradient,
    required this.fill,
    required this.separator,
    required this.selected,
    required this.onSelected,
    required this.bar,
  });

  factory JoblyColors.fromTokens(JoblyTokens t) => JoblyColors(
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [for (final color in t.gradient) Color(color)],
    ),
    fill: Color(t.fill),
    separator: Color(t.separator),
    selected: Color(t.selected),
    onSelected: Color(t.onSelected),
    bar: Color(t.bar),
  );

  static final light = JoblyColors.fromTokens(JoblyTokens.light);
  static final dark = JoblyColors.fromTokens(JoblyTokens.dark);

  final LinearGradient gradient;
  final Color fill;
  final Color separator;
  final Color selected;
  final Color onSelected;
  final Color bar;

  @override
  JoblyColors copyWith({
    LinearGradient? gradient,
    Color? fill,
    Color? separator,
    Color? selected,
    Color? onSelected,
    Color? bar,
  }) {
    return JoblyColors(
      gradient: gradient ?? this.gradient,
      fill: fill ?? this.fill,
      separator: separator ?? this.separator,
      selected: selected ?? this.selected,
      onSelected: onSelected ?? this.onSelected,
      bar: bar ?? this.bar,
    );
  }

  @override
  JoblyColors lerp(JoblyColors? other, double t) {
    if (other == null) return this;
    return JoblyColors(
      gradient: LinearGradient.lerp(gradient, other.gradient, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      onSelected: Color.lerp(onSelected, other.onSelected, t)!,
      bar: Color.lerp(bar, other.bar, t)!,
    );
  }
}

extension JoblyColorsX on ThemeData {
  JoblyColors get jobly => extension<JoblyColors>() ?? JoblyColors.light;
}
