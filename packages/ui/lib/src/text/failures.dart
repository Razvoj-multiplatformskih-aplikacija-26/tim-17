import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'domain_errors.dart';

const serverUnreachableMessage = 'Nema veze sa serverom.';
const sessionExpiredMessage = 'Prijava je istekla. Prijavite se ponovo.';
const unavailableMessage = 'Podaci trenutno nisu dostupni.';

String failureMessage(Object? cause) => switch (cause) {
  RepositoryException(failure: RepositoryFailure.unreachable) => serverUnreachableMessage,
  RepositoryException(failure: RepositoryFailure.serverError) => 'Greška na serveru.',
  RepositoryException(failure: RepositoryFailure.refused) => 'Server nije prihvatio zahtev.',
  RepositoryException(failure: RepositoryFailure.sessionExpired) => sessionExpiredMessage,
  final DomainError error => error.message,
  _ => unavailableMessage,
};
