import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';

@immutable
final class MotivationLetter {
  const MotivationLetter._(this.text);

  factory MotivationLetter.stored(String text) => MotivationLetter._(text.trim());

  static const minLength = 20;
  static const maxLength = 500;

  final String text;

  int get length => text.characters.length;

  static Result<MotivationLetter> parse(String input) {
    final text = input.trim();
    final length = text.characters.length;
    if (length < minLength) return Failure(LetterTooShort(length, min: minLength));
    if (length > maxLength) return Failure(LetterTooLong(length, max: maxLength));
    return Success(MotivationLetter._(text));
  }

  @override
  bool operator ==(Object other) => other is MotivationLetter && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'MotivationLetter($length)';
}
