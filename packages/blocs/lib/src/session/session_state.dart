part of 'session_bloc.dart';

enum SignOutReason { loggedOut, expired, unreachable, roleNotAllowed }

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];

  @override
  String toString() => '$runtimeType';
}

final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class SignedOut extends SessionState {
  const SignedOut({this.reason});

  final SignOutReason? reason;

  @override
  List<Object?> get props => [reason];

  @override
  String toString() => 'SignedOut(${reason?.name})';
}

final class SignedIn extends SessionState {
  const SignedIn(this.user);

  final User user;

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'SignedIn(${user.username})';
}
