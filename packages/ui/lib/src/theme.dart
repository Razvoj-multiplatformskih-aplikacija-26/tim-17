import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

abstract final class JoblyTheme {
  static ThemeData light() => _build(ColorScheme.fromSeed(seedColor: const Color(BrandColors.seed)));

  static ThemeData dark() =>
      _build(ColorScheme.fromSeed(seedColor: const Color(BrandColors.seed), brightness: Brightness.dark));

  static ThemeData _build(ColorScheme scheme) {
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg));
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(64, 48), shape: rounded),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48), shape: rounded),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      focusColor: scheme.primary.withValues(alpha: 0.12),
    );
  }
}
