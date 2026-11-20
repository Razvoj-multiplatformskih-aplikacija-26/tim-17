import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'login_form_event.dart';
part 'login_form_state.dart';

final class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  LoginFormBloc({required this.logIn}) : super(const LoginIdle()) {
    on<LoginSubmitted>((event, emit) async {
      emit(const LoginSubmitting());
      try {
        final user = await logIn(username: event.username, password: event.password);
        emit(user == null ? const LoginRejected() : LoginSucceeded(user));
      } on Exception catch (cause) {
        emit(LoginFailed(cause));
      }
    });
  }

  final LogIn logIn;
}
