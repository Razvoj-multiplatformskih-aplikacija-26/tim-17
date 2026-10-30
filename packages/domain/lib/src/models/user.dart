import '../identifiers.dart';

enum UserRole { student, employer, staff }

class User {
  const User({required this.id, required this.role, required this.firstName, required this.lastName});

  final UserId id;
  final UserRole role;
  final String firstName;
  final String lastName;
}
