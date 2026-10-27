sealed class DomainError {
  const DomainError();
}

final class NotAllowed extends DomainError {
  const NotAllowed();
}

final class NotFound extends DomainError {
  const NotFound();
}
