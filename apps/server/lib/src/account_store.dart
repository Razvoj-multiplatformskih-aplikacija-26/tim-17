import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

final class Account {
  const Account({required this.user, required this.passwordHash});

  final User user;
  final String passwordHash;
}

final class AccountStore {
  const AccountStore(this._database);

  final Pool<void> _database;

  Future<Account?> account(String username) async {
    final rows = await _database.execute(
      Sql.named(
        'SELECT id, username, role, first_name, last_name, password_hash FROM users '
        'WHERE username = @username AND password_hash IS NOT NULL',
      ),
      parameters: {'username': username},
    );
    if (rows.isEmpty) return null;
    final [id, login, role, firstName, lastName, hash] = rows.single;
    return Account(
      user: User(
        id: UserId(id! as String),
        username: login! as String,
        role: UserRole.values.byName(role! as String),
        firstName: firstName! as String,
        lastName: lastName! as String,
      ),
      passwordHash: hash! as String,
    );
  }
}
