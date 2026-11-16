import 'json.dart';

final class LoginDto {
  const LoginDto({required this.username, required this.password, this.cookie = false});

  final String username;
  final String password;
  final bool cookie;

  Map<String, Object?> toJson() => {'username': username, 'password': password, 'cookie': cookie};

  factory LoginDto.fromJson(Map<String, Object?> json) => LoginDto(
    username: jsonString(json, 'username'),
    password: jsonString(json, 'password'),
    cookie: json['cookie'] == true,
  );
}

final class UserDto {
  const UserDto({
    required this.id,
    required this.username,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  static const student = 'student';
  static const employer = 'employer';
  static const staff = 'staff';

  final String id;
  final String username;
  final String role;
  final String firstName;
  final String lastName;

  Map<String, Object?> toJson() => {
    'id': id,
    'username': username,
    'role': role,
    'firstName': firstName,
    'lastName': lastName,
  };

  factory UserDto.fromJson(Map<String, Object?> json) => UserDto(
    id: jsonString(json, 'id'),
    username: jsonString(json, 'username'),
    role: jsonString(json, 'role'),
    firstName: jsonString(json, 'firstName'),
    lastName: jsonString(json, 'lastName'),
  );
}

final class SessionDto {
  const SessionDto({required this.user, required this.expiresAt, this.token});

  final UserDto user;
  final DateTime expiresAt;
  final String? token;

  Map<String, Object?> toJson() => {'user': user.toJson(), 'expiresAt': instantToJson(expiresAt), 'token': ?token};

  factory SessionDto.fromJson(Map<String, Object?> json) => SessionDto(
    user: UserDto.fromJson(jsonObject(json['user'])),
    expiresAt: jsonInstant(json, 'expiresAt'),
    token: jsonOptionalString(json, 'token'),
  );
}
