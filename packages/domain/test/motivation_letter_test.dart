import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  String text(int length) => 'a' * length;

  test('prazno pismo vraća LetterTooShort(0)', () {
    expect(
      MotivationLetter.parse('   '),
      const Failure<MotivationLetter>(LetterTooShort(0, min: MotivationLetter.minLength)),
    );
  });

  test('${MotivationLetter.minLength - 1} znakova je prekratko', () {
    expect(
      MotivationLetter.parse(text(MotivationLetter.minLength - 1)),
      const Failure<MotivationLetter>(LetterTooShort(MotivationLetter.minLength - 1, min: MotivationLetter.minLength)),
    );
  });

  test('tačno ${MotivationLetter.minLength} znakova prolazi', () {
    expect(MotivationLetter.parse(text(MotivationLetter.minLength)).isSuccess, isTrue);
  });

  test('tačno ${MotivationLetter.maxLength} znakova prolazi', () {
    expect(MotivationLetter.parse(text(MotivationLetter.maxLength)).isSuccess, isTrue);
  });

  test('${MotivationLetter.maxLength + 1} znakova je predugačko', () {
    expect(
      MotivationLetter.parse(text(MotivationLetter.maxLength + 1)),
      const Failure<MotivationLetter>(LetterTooLong(MotivationLetter.maxLength + 1, max: MotivationLetter.maxLength)),
    );
  });

  test('razmaci na krajevima se ne broje', () {
    final letter = MotivationLetter.parse('  ${text(MotivationLetter.minLength)}  ').valueOrNull!;
    expect(letter.length, MotivationLetter.minLength);
  });

  test('slova sa kvačicama se broje kao jedan znak', () {
    final input = 'š' * MotivationLetter.minLength;
    expect(MotivationLetter.parse(input).valueOrNull?.length, MotivationLetter.minLength);
  });
}
