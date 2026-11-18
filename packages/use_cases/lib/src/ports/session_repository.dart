import 'package:domain/domain.dart';

abstract interface class SessionRepository {
  Future<User?> logIn({required String username, required String password});

  Future<User?> current();

  Future<void> logOut();

  Stream<void> get expirations;
}
