import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpSessionRepository implements SessionRepository {
  const HttpSessionRepository(this._api);

  final ApiClient _api;

  @override
  Future<User?> logIn({required String username, required String password}) async {
    final login = LoginDto(username: username, password: password, cookie: _api.keepsSessionInCookie);
    final answer = await _api.post(ApiPaths.sessions, body: login.toJson());
    if (answer case ApiRefused(problem: ProblemDto(code: ErrorCodes.invalidCredentials))) return null;
    final session = accepted(answer, (json) => SessionDto.fromJson(object(json)));
    if (session.token case final token?) await _api.tokens.write(token);
    return session.user.toDomain();
  }

  @override
  Future<User?> current() async {
    if (!_api.keepsSessionInCookie && await _api.tokens.read() == null) return null;
    try {
      final answer = await _api.get(ApiPaths.currentSession);
      return accepted<User>(answer, (json) => SessionDto.fromJson(object(json)).user.toDomain());
    } on RepositoryException catch (error) {
      if (error.failure != RepositoryFailure.sessionExpired) rethrow;
      await _api.tokens.clear();
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _api.delete(ApiPaths.currentSession);
    } finally {
      await _api.tokens.clear();
    }
  }

  @override
  Stream<void> get expirations => _api.expirations;
}
