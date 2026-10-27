import 'package:domain/domain.dart';

extension DomainErrorMessage on DomainError {
  String get message => switch (this) {
    NotAllowed() => 'Nemate pravo na ovu radnju.',
    NotFound() => 'Zapis nije pronađen.',
  };
}
