import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final class FakeSessions implements SessionRepository {
  FakeSessions(this._user, {bool signedIn = true}) : _current = signedIn ? _user : null;

  final User _user;
  User? _current;

  @override
  Future<User?> logIn({required String username, required String password}) async =>
      _current = password.isEmpty ? null : _user;

  @override
  Future<User?> current() async => _current;

  @override
  Future<void> logOut() async => _current = null;

  @override
  Stream<void> get expirations => const Stream.empty();
}
