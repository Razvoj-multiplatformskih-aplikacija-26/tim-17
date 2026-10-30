import 'package:design_tokens/design_tokens.dart';
import 'package:test/test.dart';

void main() {
  test('razmaci rastu', () {
    expect([Spacing.xs, Spacing.sm, Spacing.md, Spacing.lg, Spacing.xl, Spacing.xxl], [4, 8, 12, 16, 24, 32]);
  });
}
