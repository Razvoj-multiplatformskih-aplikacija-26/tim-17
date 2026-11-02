abstract final class FontFamilies {
  static const body = 'Inter';
}

final class TypeStyleTokens {
  const TypeStyleTokens({
    required this.size,
    required this.weight,
    this.family = FontFamilies.body,
    this.height,
    this.letterSpacing = 0,
  });

  final String family;
  final double size;
  final int weight;
  final double? height;
  final double letterSpacing;
}

abstract final class TypeScale {
  static const displaySmall = TypeStyleTokens(size: 34, weight: 700, height: 1.1, letterSpacing: -0.8);
  static const headlineMedium = TypeStyleTokens(size: 28, weight: 700, letterSpacing: -0.6);
  static const headlineSmall = TypeStyleTokens(size: 22, weight: 700, letterSpacing: -0.4);
  static const titleLarge = TypeStyleTokens(size: 20, weight: 600, letterSpacing: -0.3);
  static const titleMedium = TypeStyleTokens(size: 17, weight: 600, letterSpacing: -0.3);
  static const titleSmall = TypeStyleTokens(size: 15, weight: 600, letterSpacing: -0.2);
  static const bodyLarge = TypeStyleTokens(size: 17, weight: 400, letterSpacing: -0.3);
  static const bodyMedium = TypeStyleTokens(size: 15, weight: 400, letterSpacing: -0.2);
  static const bodySmall = TypeStyleTokens(size: 13, weight: 400, letterSpacing: -0.1);
  static const labelLarge = TypeStyleTokens(size: 16, weight: 600, letterSpacing: -0.2);
  static const labelMedium = TypeStyleTokens(size: 14, weight: 600, letterSpacing: -0.1);
  static const labelSmall = TypeStyleTokens(size: 11, weight: 600);
}
