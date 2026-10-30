import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

void main() {
  test('fiksni sat uvek vraća isti trenutak u UTC', () {
    final clock = FixedClock(DateTime(2026, 10, 27, 12));
    expect(clock.now(), DateTime(2026, 10, 27, 12).toUtc());
    expect(clock.now().isUtc, isTrue);
  });
}
