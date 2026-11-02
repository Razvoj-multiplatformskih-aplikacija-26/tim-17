import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';

Future<AppDependencies> _openApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final dependencies = AppDependencies.fake(latency: Duration.zero);
  await tester.pumpWidget(JoblyApp(dependencies: dependencies, themeMode: ThemeMode.light));
  await tester.pumpAndSettle();
  return dependencies;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('aplikacija se otvara na oglasima i prelazi na moje prijave', (tester) async {
    await _openApp(tester);
    expect(find.text('Radnik u magacinu'), findsOneWidget);
    expect(find.text('10 oglasa'), findsOneWidget);

    await _openTab(tester, 'Moje prijave');
    expect(find.text('Konobar / konobarica'), findsOneWidget);
  });

  testWidgets('izbor grada se vidi kao oznaka i može da se ukloni', (tester) async {
    await _openApp(tester);

    await tester.tap(find.text('Grad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zrenjanin'));
    await tester.tap(find.text('Gotovo'));
    await tester.pumpAndSettle();

    expect(find.text('Nema oglasa za ovu pretragu'), findsOneWidget);
    expect(find.bySemanticsLabel('Ukloni filter Zrenjanin'), findsOneWidget);

    await tester.tap(find.text('Obriši sve'));
    await tester.pumpAndSettle();
    expect(find.text('Radnik u magacinu'), findsOneWidget);
  });

  testWidgets('dodir na kategoriju je bira kao filter', (tester) async {
    await _openApp(tester);

    await tester.tap(find.bySemanticsLabel('Kategorija Prodaja'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Ukloni filter Prodaja'), findsOneWidget);
    expect(find.bySemanticsLabel('Filteri, izabrano 1'), findsOneWidget);
    expect(find.text('2 oglasa'), findsOneWidget);
  });

  testWidgets('sortiranje menja oznaku pored broja oglasa', (tester) async {
    await _openApp(tester);

    await tester.tap(find.text('Najnovije'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Najveća satnica'));
    await tester.pumpAndSettle();

    expect(find.text('Najveća satnica'), findsOneWidget);
  });

  testWidgets('prekidač menja svetlu temu u tamnu', (tester) async {
    await _openApp(tester);
    expect(Theme.of(tester.element(find.text('Poslovi').last)).brightness, Brightness.light);

    await tester.tap(find.byTooltip('Tamna tema'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Poslovi').last)).brightness, Brightness.dark);
  });

  testWidgets('forma proverava pismo pravilom iz domena, pa šalje prijavu', (tester) async {
    await _openApp(tester);

    await _tapVisible(tester, find.text('Prodavac u knjižari'));
    expect(find.text('Knjižara Delfi'), findsOneWidget);
    await _tapVisible(tester, find.text('Prijavi se'));

    await tester.enterText(find.byType(TextField), 'Kratko');
    await tester.pump();
    expect(find.text('Motivaciono pismo mora imati bar 20 znakova (sada 6).'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Volim knjige i rad sa ljudima, a slobodan sam popodne.');
    await tester.pump();
    expect(find.textContaining('mora imati bar'), findsNothing);

    await tester.tap(find.text('Pošalji prijavu'));
    await tester.pumpAndSettle();

    expect(find.text('Prijava je poslata.'), findsOneWidget);
    expect(find.text('Na čekanju'), findsOneWidget);
    expect(find.text('Volim knjige i rad sa ljudima, a slobodan sam popodne.'), findsOneWidget);
  });

  testWidgets('prijava na popunjen oglas javlja grešku iz domena na srpskom', (tester) async {
    await _openApp(tester);

    await _tapVisible(tester, find.text('Pomoćni radnik u pekari'));
    await _tapVisible(tester, find.text('Prijavi se'));
    await tester.enterText(find.byType(TextField), 'Radio sam noćne smene u pekari prošle godine.');
    await tester.tap(find.text('Pošalji prijavu'));
    await tester.pumpAndSettle();

    expect(find.text('Sva mesta na ovom oglasu su popunjena.'), findsOneWidget);
  });

  testWidgets('povlačenje traži potvrdu i menja stanje prijave', (tester) async {
    await _openApp(tester);
    await _openTab(tester, 'Moje prijave');

    await _tapVisible(tester, find.text('Radnik u magacinu'));
    await _tapVisible(tester, find.text('Povuci prijavu'));
    expect(find.text('Povući prijavu?'), findsOneWidget);

    await tester.tap(find.text('Odustani'));
    await tester.pumpAndSettle();
    expect(find.text('Na čekanju'), findsOneWidget);

    await tester.tap(find.text('Povuci prijavu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Povuci prijavu'));
    await tester.pumpAndSettle();

    expect(find.text('Prijava je povučena.'), findsOneWidget);
    expect(find.text('Povučena'), findsOneWidget);
    expect(find.text('Povuci prijavu'), findsNothing);
  });

  testWidgets('pilule filtriraju prijave po stanju', (tester) async {
    await _openApp(tester);
    await _openTab(tester, 'Moje prijave');

    final pills = find.byWidgetPredicate((widget) => widget is ListView && widget.scrollDirection == Axis.horizontal);
    await tester.dragUntilVisible(find.text('Završene'), pills, const Offset(-120, 0));
    await tester.tap(find.text('Završene'));
    await tester.pumpAndSettle();
    expect(find.text('Popis robe'), findsOneWidget);
    expect(find.text('Radnik u magacinu'), findsNothing);
  });

  testWidgets('demo meni izaziva grešku, a Pokušaj ponovo vraća podatke', (tester) async {
    await _openApp(tester);

    await tester.tap(find.byTooltip('Demo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Greška u sledećem zahtevu'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Demo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ponovo učitaj'));
    await tester.pumpAndSettle();

    expect(find.text('Pokušaj ponovo'), findsOneWidget);
    await tester.tap(find.text('Pokušaj ponovo'));
    await tester.pumpAndSettle();
    expect(find.text('Radnik u magacinu'), findsOneWidget);
  });

  testWidgets('prazan odgovor prikazuje prazno stanje mojih prijava', (tester) async {
    final dependencies = await _openApp(tester);
    await _openTab(tester, 'Moje prijave');

    dependencies.fakeJobBoard!
      ..answerEmptyNext()
      ..answerEmptyNext();
    await tester.tap(find.byTooltip('Demo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ponovo učitaj'));
    await tester.pumpAndSettle();

    expect(find.text('Još nemaš prijava'), findsOneWidget);
  });
}
