import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'application_mapping.dart';

extension DomainErrorMapping on DomainError {
  ProblemDto toProblem() => switch (this) {
    LetterTooShort(:final length, :final min) => ProblemDto(
      status: 422,
      code: ErrorCodes.letterTooShort,
      title: 'Motivation letter too short',
      value: length,
      min: min,
    ),
    LetterTooLong(:final length, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.letterTooLong,
      title: 'Motivation letter too long',
      value: length,
      max: max,
    ),
    JobClosed() => const ProblemDto(status: 409, code: ErrorCodes.jobClosed, title: 'Job posting closed'),
    NoSlotsLeft() => const ProblemDto(status: 409, code: ErrorCodes.noSlotsLeft, title: 'No slots left'),
    AlreadyApplied() => const ProblemDto(status: 409, code: ErrorCodes.alreadyApplied, title: 'Already applied'),
    TooManyActive(:final max) => ProblemDto(
      status: 409,
      code: ErrorCodes.tooManyActive,
      title: 'Too many active applications',
      max: max,
    ),
    InvalidTransition(:final from, :final to) => ProblemDto(
      status: 409,
      code: ErrorCodes.invalidTransition,
      title: 'Invalid transition',
      from: from.toDto(),
      to: to.toDto(),
    ),
    NotAllowed() => const ProblemDto(status: 403, code: ErrorCodes.notAllowed, title: 'Not allowed'),
    NotFound() => const ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'Not found'),
  };
}

extension ProblemMapping on ProblemDto {
  DomainError? toDomainError() => switch (this) {
    ProblemDto(code: ErrorCodes.letterTooShort, :final value?, :final min?) => LetterTooShort(value, min: min),
    ProblemDto(code: ErrorCodes.letterTooLong, :final value?, :final max?) => LetterTooLong(value, max: max),
    ProblemDto(code: ErrorCodes.jobClosed) => const JobClosed(),
    ProblemDto(code: ErrorCodes.noSlotsLeft) => const NoSlotsLeft(),
    ProblemDto(code: ErrorCodes.alreadyApplied) => const AlreadyApplied(),
    ProblemDto(code: ErrorCodes.tooManyActive, :final max?) => TooManyActive(max),
    ProblemDto(code: ErrorCodes.invalidTransition, :final from?, :final to?) => _transition(from, to),
    ProblemDto(code: ErrorCodes.notAllowed) => const NotAllowed(),
    ProblemDto(code: ErrorCodes.notFound) => const NotFound(),
    _ => null,
  };
}

DomainError? _transition(String from, String to) {
  try {
    return InvalidTransition(from: applicationStatusFromDto(from), to: applicationStatusFromDto(to));
  } on FormatException {
    return null;
  }
}
