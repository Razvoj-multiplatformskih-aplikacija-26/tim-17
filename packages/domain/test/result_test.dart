import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  test('Success nosi vrednost, a Failure grešku kao tip', () {
    expect(const Success(42).valueOrNull, 42);
    expect(const Failure<int>(NotFound()).errorOrNull, isA<NotFound>());
    expect(const Failure<int>(NotFound()).isSuccess, isFalse);
  });
}
