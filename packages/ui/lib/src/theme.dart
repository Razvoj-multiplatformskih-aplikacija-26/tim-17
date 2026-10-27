import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import 'jobly_colors.dart';

abstract final class JoblyTheme {
  static ThemeData light() => _build(_scheme(ColorTokens.light, Brightness.light), JoblyColors.light);

  static ThemeData dark() => _build(_scheme(ColorTokens.dark, Brightness.dark), JoblyColors.dark);

  static ThemeData _build(ColorScheme scheme, JoblyColors jobly) {
    final textTheme = _textTheme(ThemeData(colorScheme: scheme).textTheme);
    const capsule = StadiumBorder();
    return ThemeData(
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          shape: capsule,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          foregroundColor: scheme.onSurface,
          shape: capsule,
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44), foregroundColor: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: jobly.fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.md), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: scheme.error),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 70,
        indicatorColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 30,
            color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontSize: 12,
            color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.brightness == Brightness.dark ? scheme.surfaceContainer : scheme.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: scheme.outline,
        dragHandleSize: const Size(36, 5),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: jobly.fill,
        thumbColor: Colors.white,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        tickMarkShape: SliderTickMarkShape.noTickMark,
      ),
      dividerTheme: DividerThemeData(color: jobly.separator, thickness: 0.5, space: 0.5),
      focusColor: scheme.primary.withValues(alpha: 0.16),
      extensions: [jobly],
    );
  }

  // Veličine i težine po uzoru na iOS tipografiju.
  static TextTheme _textTheme(TextTheme t) => t.copyWith(
    displaySmall: t.displaySmall?.copyWith(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.8, height: 1.1),
    headlineMedium: t.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6),
    headlineSmall: t.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4),
    titleLarge: t.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
    titleMedium: t.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3),
    titleSmall: t.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    bodyLarge: t.bodyLarge?.copyWith(fontSize: 17, letterSpacing: -0.3),
    bodyMedium: t.bodyMedium?.copyWith(fontSize: 15, letterSpacing: -0.2),
    bodySmall: t.bodySmall?.copyWith(fontSize: 13, letterSpacing: -0.1),
    labelLarge: t.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    labelMedium: t.labelMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.1),
    labelSmall: t.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0),
  );

  static ColorScheme _scheme(ColorTokens t, Brightness brightness) => ColorScheme(
    brightness: brightness,
    primary: Color(t.primary),
    onPrimary: Color(t.onPrimary),
    primaryContainer: Color(t.primaryContainer),
    onPrimaryContainer: Color(t.onPrimaryContainer),
    secondary: Color(t.secondary),
    onSecondary: Color(t.onSecondary),
    tertiary: Color(t.tertiary),
    onTertiary: Color(t.onTertiary),
    error: Color(t.error),
    onError: Color(t.onError),
    errorContainer: Color(t.errorContainer),
    onErrorContainer: Color(t.onErrorContainer),
    surface: Color(t.surface),
    onSurface: Color(t.onSurface),
    surfaceContainerLowest: Color(t.surfaceContainerLowest),
    surfaceContainerLow: Color(t.surfaceContainerLow),
    surfaceContainer: Color(t.surfaceContainer),
    surfaceContainerHigh: Color(t.surfaceContainerHigh),
    surfaceContainerHighest: Color(t.surfaceContainerHighest),
    onSurfaceVariant: Color(t.onSurfaceVariant),
    outline: Color(t.outline),
    outlineVariant: Color(t.outlineVariant),
    inverseSurface: Color(t.inverseSurface),
    onInverseSurface: Color(t.onInverseSurface),
    inversePrimary: Color(t.inversePrimary),
  );
}
