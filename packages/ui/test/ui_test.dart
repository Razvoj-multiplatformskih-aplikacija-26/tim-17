import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';
import 'package:use_cases/use_cases.dart';

const _student = User(
  id: UserId('u-student'),
  username: 'student1',
  role: UserRole.student,
  firstName: 'Ana',
  lastName: 'Ilić',
);

final class _Sessions implements SessionRepository {
  bool unreachable = false;

  @override
  Future<User?> logIn({required String username, required String password}) async {
    if (unreachable) throw const RepositoryException('offline', failure: RepositoryFailure.unreachable);
    return password == 'jobly-demo' ? _student : null;
  }

  @override
  Future<User?> current() async => null;

  @override
  Future<void> logOut() async {}

  @override
  Stream<void> get expirations => const Stream.empty();
}

void main() {
  test('pluralize bira oblik po srpskim pravilima', () {
    String posao(int n) => pluralize(n, one: 'posao', few: 'posla', many: 'poslova');
    expect([posao(1), posao(3), posao(5), posao(11), posao(21)], ['posao', 'posla', 'poslova', 'poslova', 'posao']);
  });

  testWidgets('FailureView nudi dugme Pokušaj ponovo', (tester) async {
    var retried = false;
    await tester.pumpWidget(MaterialApp(home: FailureView(onRetry: () => retried = true)));
    expect(find.text(unavailableMessage), findsOneWidget);
    await tester.tap(find.text('Pokušaj ponovo'));
    expect(retried, isTrue);
  });

  testWidgets('FailureView kaže kada server nije dostupan', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FailureView(
          onRetry: () {},
          cause: const RepositoryException('offline', failure: RepositoryFailure.unreachable),
        ),
      ),
    );
    expect(find.text(serverUnreachableMessage), findsOneWidget);
  });

  group('LoginScreen', () {
    late _Sessions sessions;
    User? signedIn;

    Future<void> pump(WidgetTester tester, {SignOutReason? reason}) => tester.pumpWidget(
      MaterialApp(
        theme: JoblyTheme.light(),
        home: LoginScreen(
          title: 'Prijava',
          logIn: LogIn(sessions: sessions),
          onSignedIn: (user) => signedIn = user,
          roleNotAllowedMessage: 'Samo za studente.',
          reason: reason,
        ),
      ),
    );

    Future<void> submit(WidgetTester tester, String password) async {
      await tester.enterText(find.widgetWithText(TextField, 'Korisničko ime'), 'student1');
      await tester.enterText(find.widgetWithText(TextField, 'Lozinka'), password);
      await tester.tap(find.text('Prijavi se'));
      await tester.pumpAndSettle();
    }

    setUp(() {
      sessions = _Sessions();
      signedIn = null;
    });

    testWidgets('ispravna prijava javlja korisnika', (tester) async {
      await pump(tester);
      await submit(tester, 'jobly-demo');
      expect(signedIn, _student);
    });

    testWidgets('pogrešna lozinka prikazuje poruku', (tester) async {
      await pump(tester);
      await submit(tester, 'pogresno');
      expect(find.text('Pogrešno korisničko ime ili lozinka.'), findsOneWidget);
      expect(signedIn, isNull);
    });

    testWidgets('nedostupan server prikazuje poruku', (tester) async {
      sessions.unreachable = true;
      await pump(tester);
      await submit(tester, 'jobly-demo');
      expect(find.text(serverUnreachableMessage), findsOneWidget);
    });

    testWidgets('razlog odjave se prikazuje', (tester) async {
      await pump(tester, reason: SignOutReason.expired);
      expect(find.text(sessionExpiredMessage), findsOneWidget);
      await pump(tester, reason: SignOutReason.roleNotAllowed);
      expect(find.text('Samo za studente.'), findsOneWidget);
    });
  });
}
