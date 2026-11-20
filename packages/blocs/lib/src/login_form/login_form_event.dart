part of 'login_form_bloc.dart';

sealed class LoginFormEvent {
  const LoginFormEvent();
}

final class LoginSubmitted extends LoginFormEvent {
  const LoginSubmitted({required this.username, required this.password});

  final String username;
  final String password;
}
