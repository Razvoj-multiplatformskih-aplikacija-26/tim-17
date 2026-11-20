import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

const _student = User(
  id: UserId('u-student'),
  username: 'student1',
  role: UserRole.student,
  firstName: 'Ana',
  lastName: 'Ilić',
);

Future<void> _open(WidgetTester tester, BackofficeDependencies dependencies) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(BackofficeApp(dependencies: dependencies, themeMode: ThemeMode.light));
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextField, 'Korisničko ime'), 'referent1');
  await tester.enterText(find.widgetWithText(TextField, 'Lozinka'), 'jobly-demo');
  await tester.tap(find.text('Prijavi se'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('referent se prijavljuje i vidi svoje ime u traci sa strane', (tester) async {
    await _open(tester, BackofficeDependencies.fake(latency: Duration.zero, signedIn: false));
    expect(find.text('Backoffice za osoblje zadruge'), findsOneWidget);

    await _signIn(tester);
    expect(find.text('Prijave kandidata'), findsOneWidget);
    expect(find.text(staffReferent.fullName), findsOneWidget);
  });

  testWidgets('student ne može da se prijavi u backoffice', (tester) async {
    await _open(tester, BackofficeDependencies.fake(latency: Duration.zero, staff: _student, signedIn: false));
    await _signIn(tester);
    expect(find.text('Backoffice je za osoblje zadruge.'), findsOneWidget);
    expect(find.text('Prijave kandidata'), findsNothing);
  });

  testWidgets('odjava vraća na prijavu', (tester) async {
    await _open(tester, BackofficeDependencies.fake(latency: Duration.zero));
    await tester.tap(find.byTooltip('Odjavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Backoffice za osoblje zadruge'), findsOneWidget);
  });

  testWidgets('istekla sesija vraća na prijavu sa porukom', (tester) async {
    await _open(tester, BackofficeDependencies.fake(latency: Duration.zero));
    tester.element(find.text('Prijave kandidata')).read<SessionBloc>().add(const SessionExpired());
    await tester.pumpAndSettle();
    expect(find.text(sessionExpiredMessage), findsOneWidget);
  });

  testWidgets('R i dugme Osveži ponovo učitavaju prijave', (tester) async {
    final dependencies = BackofficeDependencies.fake(latency: Duration.zero);
    await _open(tester, dependencies);
    dependencies.fakeBoard!.failNextRequest();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.pumpAndSettle();
    expect(find.text('Pokušaj ponovo'), findsOneWidget);

    await tester.tap(find.byTooltip('Osveži (R)'));
    await tester.pumpAndSettle();
    expect(find.text('Pokušaj ponovo'), findsNothing);
  });
}
