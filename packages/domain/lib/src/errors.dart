import 'package:meta/meta.dart';

import 'models/application_status.dart';

sealed class DomainError {
  const DomainError();
}

@immutable
final class LetterTooShort extends DomainError {
  const LetterTooShort(this.length);

  final int length;

  @override
  bool operator ==(Object other) => other is LetterTooShort && other.length == length;

  @override
  int get hashCode => Object.hash(LetterTooShort, length);

  @override
  String toString() => 'LetterTooShort($length)';
}

@immutable
final class LetterTooLong extends DomainError {
  const LetterTooLong(this.length);

  final int length;

  @override
  bool operator ==(Object other) => other is LetterTooLong && other.length == length;

  @override
  int get hashCode => Object.hash(LetterTooLong, length);

  @override
  String toString() => 'LetterTooLong($length)';
}

final class JobClosed extends DomainError {
  const JobClosed();
}

final class NoSlotsLeft extends DomainError {
  const NoSlotsLeft();
}

final class AlreadyApplied extends DomainError {
  const AlreadyApplied();
}

@immutable
final class TooManyActive extends DomainError {
  const TooManyActive(this.max);

  final int max;

  @override
  bool operator ==(Object other) => other is TooManyActive && other.max == max;

  @override
  int get hashCode => Object.hash(TooManyActive, max);

  @override
  String toString() => 'TooManyActive($max)';
}

@immutable
final class InvalidTransition extends DomainError {
  const InvalidTransition({required this.from, required this.to});

  final ApplicationStatus from;
  final ApplicationStatus to;

  @override
  bool operator ==(Object other) => other is InvalidTransition && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(InvalidTransition, from, to);

  @override
  String toString() => 'InvalidTransition(${from.name} -> ${to.name})';
}

final class NotAllowed extends DomainError {
  const NotAllowed();
}

final class NotFound extends DomainError {
  const NotFound();
}
