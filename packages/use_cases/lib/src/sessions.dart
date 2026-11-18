import 'package:domain/domain.dart';

import 'ports/session_repository.dart';

final class LogIn {
  const LogIn({required this.sessions});

  final SessionRepository sessions;

  Future<User?> call({required String username, required String password}) =>
      sessions.logIn(username: username.trim(), password: password);
}

final class RestoreSession {
  const RestoreSession({required this.sessions});

  final SessionRepository sessions;

  Future<User?> call() => sessions.current();
}

final class LogOut {
  const LogOut({required this.sessions});

  final SessionRepository sessions;

  Future<void> call() => sessions.logOut();
}
