import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/screens/jobs_screen.dart';
import 'package:ui/ui.dart';
import 'package:use_cases/use_cases.dart';

Future<void> _open(WidgetTester tester, AppDependencies dependencies) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(JoblyApp(dependencies: dependencies, themeMode: ThemeMode.light));
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester, {String password = 'jobly-demo'}) async {
  await tester.enterText(find.widgetWithText(TextField, 'Korisničko ime'), 'student1');
  await tester.enterText(find.widgetWithText(TextField, 'Lozinka'), password);
  await tester.tap(find.text('Prijavi se'));
  await tester.pumpAndSettle();
}

final class _Staff implements SessionRepository {
  int logOuts = 0;

  @override
  Future<User?> logIn({required String username, required String password}) async => const User(
    id: UserId('u-ref'),
    username: 'referent1',
    role: UserRole.staff,
    firstName: 'Marija',
    lastName: 'Kostić',
  );

  @override
  Future<User?> current() async => null;

  @override
  Future<void> logOut() async => logOuts++;

  @override
  Stream<void> get expirations => const Stream.empty();
}

void main() {
  testWidgets('bez prijave aplikacija traži prijavu, pa otvara oglase', (tester) async {
    await _open(tester, AppDependencies.fake(latency: Duration.zero, signedIn: false));
    expect(find.text('Prijava za studente'), findsOneWidget);

    await _signIn(tester, password: '');
    expect(find.text('Pogrešno korisničko ime ili lozinka.'), findsOneWidget);

    await _signIn(tester);
    expect(find.byType(JobsScreen), findsOneWidget);
    expect(find.text('Radnik u magacinu'), findsOneWidget);
  });

  testWidgets('odjava vraća na prijavu', (tester) async {
    await _open(tester, AppDependencies.fake(latency: Duration.zero));
    await tester.tap(find.byTooltip('Odjavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Prijava za studente'), findsOneWidget);
  });

  testWidgets('istekla sesija vraća na prijavu sa porukom', (tester) async {
    await _open(tester, AppDependencies.fake(latency: Duration.zero));
    tester.element(find.byType(JobsScreen)).read<SessionBloc>().add(const SessionExpired());
    await tester.pumpAndSettle();
    expect(find.text(sessionExpiredMessage), findsOneWidget);
  });

  testWidgets('osoblje ne može da se prijavi u mobilnu aplikaciju', (tester) async {
    final sessions = _Staff();
    final fake = AppDependencies.fake(latency: Duration.zero);
    await _open(
      tester,
      AppDependencies(
        clock: fake.clock,
        jobs: fake.fakeJobBoard!,
        applications: fake.fakeJobBoard!,
        candidates: fake.fakeJobBoard!,
        sessions: sessions,
      ),
    );
    await _signIn(tester);
    expect(find.text('Aplikacija je za studente. Osoblje koristi backoffice.'), findsOneWidget);
    expect(sessions.logOuts, 1);
  });
}
