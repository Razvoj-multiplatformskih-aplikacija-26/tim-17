part of 'login_form_bloc.dart';

sealed class LoginFormState extends Equatable {
  const LoginFormState();

  @override
  List<Object?> get props => [];

  @override
  String toString() => '$runtimeType';
}

final class LoginIdle extends LoginFormState {
  const LoginIdle();
}

final class LoginSubmitting extends LoginFormState {
  const LoginSubmitting();
}

final class LoginSucceeded extends LoginFormState {
  const LoginSucceeded(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class LoginRejected extends LoginFormState {
  const LoginRejected();
}

final class LoginFailed extends LoginFormState {
  const LoginFailed(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];
}
