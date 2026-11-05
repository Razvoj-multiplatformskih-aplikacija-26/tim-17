import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

extension UserRoleMapping on UserRole {
  String toDto() => switch (this) {
    UserRole.student => UserDto.student,
    UserRole.employer => UserDto.employer,
    UserRole.staff => UserDto.staff,
  };
}

UserRole userRoleFromDto(String role) => switch (role) {
  UserDto.student => UserRole.student,
  UserDto.employer => UserRole.employer,
  UserDto.staff => UserRole.staff,
  _ => throw FormatException('Unknown role "$role"', role),
};

extension UserMapping on User {
  UserDto toDto() =>
      UserDto(id: id.value, username: username, role: role.toDto(), firstName: firstName, lastName: lastName);
}

extension UserDtoMapping on UserDto {
  User toDomain() =>
      User(id: UserId(id), username: username, role: userRoleFromDto(role), firstName: firstName, lastName: lastName);
}
