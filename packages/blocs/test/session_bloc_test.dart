import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'in_memory_jobs.dart';

final class RememberedSession implements SessionRepository {
  RememberedSession(this.remembered);

  User? remembered;
  bool unreachable = false;
  int logOuts = 0;
  final _expirations = StreamController<void>.broadcast();

  void expire() => _expirations.add(null);

  @override
  Future<User?> logIn({required String username, required String password}) async {
    if (unreachable) throw const RepositoryException('offline', failure: RepositoryFailure.unreachable);
    return username == student.username && password == 'jobly-demo' ? student : null;
  }

  @override
  Future<User?> current() async {
    if (unreachable) throw const RepositoryException('offline', failure: RepositoryFailure.unreachable);
    return remembered;
  }

  @override
  Future<void> logOut() async {
    logOuts++;
    remembered = null;
  }

  @override
  Stream<void> get expirations => _expirations.stream;
}

void main() {
  late RememberedSession sessions;

  SessionBloc build({bool Function(User user) admits = AccessPolicy.canApply}) => SessionBloc(
    restoreSession: RestoreSession(sessions: sessions),
    logOut: LogOut(sessions: sessions),
    admits: admits,
    expirations: sessions.expirations,
  );

  blocTest<SessionBloc, SessionState>(
    'zapamćena prijava preživi restart i završava se razlogom kada server kaže da je istekla',
    setUp: () => sessions = RememberedSession(student),
    build: build,
    act: (bloc) async {
      bloc.add(const SessionRestoreRequested());
      await Future<void>.delayed(Duration.zero);
      sessions.expire();
    },
    expect: () => [const SignedIn(student), const SignedOut(reason: SignOutReason.expired)],
  );

  blocTest<SessionBloc, SessionState>(
    'bez zapamćene prijave korisnik je odjavljen bez razloga',
    setUp: () => sessions = RememberedSession(null),
    build: build,
    act: (bloc) => bloc.add(const SessionRestoreRequested()),
    expect: () => [const SignedOut()],
  );

  blocTest<SessionBloc, SessionState>(
    'nedostupan server pri pokretanju vodi na prijavu sa razlogom',
    setUp: () => sessions = RememberedSession(student)..unreachable = true,
    build: build,
    act: (bloc) => bloc.add(const SessionRestoreRequested()),
    expect: () => [const SignedOut(reason: SignOutReason.unreachable)],
  );

  blocTest<SessionBloc, SessionState>(
    'uloga koju aplikacija ne prima se odbija i sesija se gasi',
    setUp: () => sessions = RememberedSession(null),
    build: () => build(admits: AccessPolicy.canReview),
    act: (bloc) => bloc.add(const SessionStarted(student)),
    expect: () => [const SignedOut(reason: SignOutReason.roleNotAllowed)],
    verify: (_) => expect(sessions.logOuts, 1),
  );

  blocTest<SessionBloc, SessionState>(
    'odjava briše sesiju',
    setUp: () => sessions = RememberedSession(student),
    build: build,
    seed: () => const SignedIn(student),
    act: (bloc) => bloc.add(const SessionLogOutRequested()),
    expect: () => [const SignedOut(reason: SignOutReason.loggedOut)],
    verify: (_) => expect(sessions.remembered, isNull),
  );

  blocTest<SessionBloc, SessionState>(
    'istek dok niko nije prijavljen ne menja stanje',
    setUp: () => sessions = RememberedSession(null),
    build: build,
    seed: () => const SignedOut(),
    act: (bloc) => sessions.expire(),
    expect: () => <SessionState>[],
  );

  group('LoginFormBloc', () {
    setUp(() => sessions = RememberedSession(null));

    LoginFormBloc buildForm() => LoginFormBloc(logIn: LogIn(sessions: sessions));

    blocTest<LoginFormBloc, LoginFormState>(
      'ispravni podaci prijavljuju korisnika',
      build: buildForm,
      act: (bloc) => bloc.add(const LoginSubmitted(username: ' ana ', password: 'jobly-demo')),
      expect: () => [const LoginSubmitting(), const LoginSucceeded(student)],
    );

    blocTest<LoginFormBloc, LoginFormState>(
      'pogrešna lozinka se odbija',
      build: buildForm,
      act: (bloc) => bloc.add(const LoginSubmitted(username: 'ana', password: 'pogresno')),
      expect: () => [const LoginSubmitting(), const LoginRejected()],
    );

    blocTest<LoginFormBloc, LoginFormState>(
      'nedostupan server javlja grešku',
      build: buildForm,
      act: (bloc) {
        sessions.unreachable = true;
        bloc.add(const LoginSubmitted(username: 'ana', password: 'jobly-demo'));
      },
      expect: () => [const LoginSubmitting(), isA<LoginFailed>()],
    );
  });
}
