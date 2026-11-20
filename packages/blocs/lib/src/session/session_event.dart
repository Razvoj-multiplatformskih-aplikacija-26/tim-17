part of 'session_bloc.dart';

sealed class SessionEvent {
  const SessionEvent();
}

final class SessionRestoreRequested extends SessionEvent {
  const SessionRestoreRequested();
}

final class SessionStarted extends SessionEvent {
  const SessionStarted(this.user);

  final User user;
}

final class SessionLogOutRequested extends SessionEvent {
  const SessionLogOutRequested();
}

final class SessionExpired extends SessionEvent {
  const SessionExpired();
}
