final class ColorTokens {
  const ColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
  });

  static const light = ColorTokens(
    primary: 0xFF6E56F7,
    onPrimary: 0xFFFFFFFF,
    primaryContainer: 0xFFEDE9FF,
    onPrimaryContainer: 0xFF24145F,
    secondary: 0xFFC455F2,
    onSecondary: 0xFFFFFFFF,
    tertiary: 0xFF4F7CFF,
    onTertiary: 0xFFFFFFFF,
    error: 0xFFFF3B30,
    onError: 0xFFFFFFFF,
    errorContainer: 0xFFFFE5E3,
    onErrorContainer: 0xFF5C0A05,
    surface: 0xFFFFFFFF,
    onSurface: 0xFF000000,
    surfaceContainerLowest: 0xFFFFFFFF,
    surfaceContainerLow: 0xFFF7F7FA,
    surfaceContainer: 0xFFF2F2F7,
    surfaceContainerHigh: 0xFFE9E9EE,
    surfaceContainerHighest: 0xFFE5E5EA,
    onSurfaceVariant: 0xFF6C6C70,
    outline: 0xFFC6C6C8,
    outlineVariant: 0xFFE5E5EA,
    inverseSurface: 0xFF1C1C1E,
    onInverseSurface: 0xFFFFFFFF,
    inversePrimary: 0xFF8B7BFF,
  );

  static const dark = ColorTokens(
    primary: 0xFF8B7BFF,
    onPrimary: 0xFFFFFFFF,
    primaryContainer: 0xFF2E2470,
    onPrimaryContainer: 0xFFEDE9FF,
    secondary: 0xFFD27BFA,
    onSecondary: 0xFF000000,
    tertiary: 0xFF7A9BFF,
    onTertiary: 0xFF000000,
    error: 0xFFFF453A,
    onError: 0xFFFFFFFF,
    errorContainer: 0xFF5C0A05,
    onErrorContainer: 0xFFFFE5E3,
    surface: 0xFF000000,
    onSurface: 0xFFFFFFFF,
    surfaceContainerLowest: 0xFF0A0A0B,
    surfaceContainerLow: 0xFF121214,
    surfaceContainer: 0xFF1C1C1E,
    surfaceContainerHigh: 0xFF2C2C2E,
    surfaceContainerHighest: 0xFF3A3A3C,
    onSurfaceVariant: 0xFFAEAEB2,
    outline: 0xFF48484A,
    outlineVariant: 0xFF38383A,
    inverseSurface: 0xFFF2F2F7,
    onInverseSurface: 0xFF000000,
    inversePrimary: 0xFF6E56F7,
  );

  final int primary;
  final int onPrimary;
  final int primaryContainer;
  final int onPrimaryContainer;
  final int secondary;
  final int onSecondary;
  final int tertiary;
  final int onTertiary;
  final int error;
  final int onError;
  final int errorContainer;
  final int onErrorContainer;
  final int surface;
  final int onSurface;
  final int surfaceContainerLowest;
  final int surfaceContainerLow;
  final int surfaceContainer;
  final int surfaceContainerHigh;
  final int surfaceContainerHighest;
  final int onSurfaceVariant;
  final int outline;
  final int outlineVariant;
  final int inverseSurface;
  final int onInverseSurface;
  final int inversePrimary;
}

final class JoblyTokens {
  const JoblyTokens({
    required this.gradient,
    required this.fill,
    required this.separator,
    required this.selected,
    required this.onSelected,
    required this.bar,
  });

  static const brandGradient = [0xFF4F7CFF, 0xFF7C5CFF, 0xFFC455F2];

  static const light = JoblyTokens(
    gradient: brandGradient,
    fill: 0xFFEFEFF0,
    separator: 0xFFE5E5EA,
    selected: 0xFF000000,
    onSelected: 0xFFFFFFFF,
    bar: 0xE6FFFFFF,
  );

  static const dark = JoblyTokens(
    gradient: brandGradient,
    fill: 0xFF2C2C2E,
    separator: 0xFF38383A,
    selected: 0xFFFFFFFF,
    onSelected: 0xFF000000,
    bar: 0xE6000000,
  );

  final List<int> gradient;

  final int fill;
  final int separator;

  final int selected;
  final int onSelected;

  final int bar;
}

final class StatusTokens {
  const StatusTokens({required this.pending, required this.accepted, required this.rejected, required this.completed});

  static const light = StatusTokens(
    pending: 0xFFD97706,
    accepted: 0xFF16A34A,
    rejected: 0xFFDC2626,
    completed: 0xFF4F6BFF,
  );

  static const dark = StatusTokens(
    pending: 0xFFFFB340,
    accepted: 0xFF30D158,
    rejected: 0xFFFF6961,
    completed: 0xFF7A9BFF,
  );

  final int pending;
  final int accepted;
  final int rejected;
  final int completed;
}
