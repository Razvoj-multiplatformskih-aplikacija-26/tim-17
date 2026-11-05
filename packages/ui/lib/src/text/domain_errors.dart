import 'package:domain/domain.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    LetterTooShort(:final length, :final min) =>
      length == 0 ? 'Motivaciono pismo je obavezno.' : 'Motivaciono pismo mora imati bar $min znakova (sada $length).',
    LetterTooLong(:final length, :final max) => 'Motivaciono pismo može imati najviše $max znakova (sada $length).',
    JobClosed() => 'Oglas je zatvoren i više ne prima prijave.',
    NoSlotsLeft() => 'Sva mesta na ovom oglasu su popunjena.',
    AlreadyApplied() => 'Već si se prijavio na ovaj oglas.',
    TooManyActive(:final max) => 'Možeš imati najviše $max aktivnih prijava u isto vreme.',
    InvalidTransition() => 'Ova promena statusa prijave nije moguća.',
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    NotFound() => 'Zapis nije pronađen.',
  };
}
