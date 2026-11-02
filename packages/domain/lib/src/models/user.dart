import 'package:meta/meta.dart';

import '../identifiers.dart';

enum UserRole {
  student,
  employer,
  staff;

  bool get isStaff => this != student;
}

@immutable
final class User {
  const User({required this.id, required this.role, required this.firstName, required this.lastName});

  final UserId id;
  final UserRole role;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.role == role &&
      other.firstName == firstName &&
      other.lastName == lastName;

  @override
  int get hashCode => Object.hash(id, role, firstName, lastName);

  @override
  String toString() => 'User($id, $role)';
}
