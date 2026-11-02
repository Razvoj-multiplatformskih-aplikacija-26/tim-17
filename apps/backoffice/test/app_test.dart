import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';

Future<BackofficeDependencies> _openApp(WidgetTester tester, {Size size = const Size(1440, 900)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final dependencies = BackofficeDependencies.fake(latency: Duration.zero);
  await tester.pumpWidget(BackofficeApp(dependencies: dependencies, themeMode: ThemeMode.light));
  await tester.pumpAndSettle();
  return dependencies;
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

Future<void> _demo(WidgetTester tester, String action) async {
  await tester.tap(find.byTooltip('Demo'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('širok prozor prikazuje traku sa strane i tabelu sa prijavama', (tester) async {
    await _openApp(tester);
    expect(find.text('Prijave kandidata'), findsOneWidget);
    expect(find.text('KANDIDAT'), findsOneWidget);
    expect(find.text('Sve 35'), findsOneWidget);
    expect(find.text('Ana Jovanović'), findsWidgets);
    expect(find.text('Nikola Vasiljević'), findsOneWidget);
    expect(find.text('Referent zadruge'), findsOneWidget);
  });

  testWidgets('prečica 2 prebacuje na kanban sa kolonom za svako stanje', (tester) async {
    await _openApp(tester);
    await _press(tester, LogicalKeyboardKey.digit2);
    for (final column in ['Na čekanju', 'Prihvaćene', 'Odbijene', 'Završene', 'Povučene']) {
      expect(find.text(column), findsWidgets);
    }
  });

  testWidgets('strelica bira prijavu, a P je prihvata', (tester) async {
    await _openApp(tester);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(find.text('Prihvati'), findsOneWidget);

    await _press(tester, LogicalKeyboardKey.keyP);
    expect(find.text('Prihvaćeno: 1 prijava'), findsOneWidget);
    expect(find.text('Označi kao završenu'), findsOneWidget);
  });

  testWidgets('odbijanje traži potvrdu', (tester) async {
    await _openApp(tester);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.keyO);
    expect(find.text('Odbiti prijavu?'), findsOneWidget);

    await tester.tap(find.text('Odbij').last);
    await tester.pumpAndSettle();
    expect(find.text('Odbijeno: 1 prijava'), findsOneWidget);
    expect(find.text('Prijava je u završnom stanju.'), findsOneWidget);
  });

  testWidgets('masovna promena menja samo prijave kojima je prelaz dozvoljen', (tester) async {
    await _openApp(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    await _press(tester, LogicalKeyboardKey.keyZ);
    expect(find.text('Završeno: 8 prijava · preskočeno 27'), findsOneWidget);
    expect(find.text('Završene 12'), findsOneWidget);
  });

  testWidgets('prihvatanje na popunjenom oglasu javlja grešku iz domena', (tester) async {
    await _openApp(tester);
    await tester.enterText(find.byType(TextField), 'pekari');
    await tester.pumpAndSettle();
    await _press(tester, LogicalKeyboardKey.escape);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.keyP);

    expect(find.text('Sva mesta na ovom oglasu su popunjena.'), findsOneWidget);
  });

  testWidgets('uzak prozor prikazuje listu i čuva izbor', (tester) async {
    await _openApp(tester);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(find.text('Prihvati'), findsOneWidget);

    tester.view.physicalSize = const Size(700, 900);
    await tester.pumpAndSettle();
    expect(find.text('KANDIDAT'), findsNothing);
    expect(find.text('Prihvati'), findsOneWidget);

    await _press(tester, LogicalKeyboardKey.escape);
    expect(find.text('Prijave kandidata'), findsOneWidget);
    expect(find.text('Prihvati'), findsNothing);
  });

  testWidgets('demo greška prikazuje Pokušaj ponovo, koji vraća podatke', (tester) async {
    await _openApp(tester);
    await _demo(tester, 'Greška u sledećem zahtevu');
    await _demo(tester, 'Ponovo učitaj');
    expect(find.text('Pokušaj ponovo'), findsOneWidget);

    await tester.tap(find.text('Pokušaj ponovo'));
    await tester.pumpAndSettle();
    expect(find.text('Sve 35'), findsOneWidget);
  });

  testWidgets('prazan odgovor prikazuje prazno stanje', (tester) async {
    await _openApp(tester);
    await _demo(tester, 'Prazan sledeći odgovor');
    await _demo(tester, 'Ponovo učitaj');
    expect(find.text('Još nema prijava'), findsOneWidget);
  });

  testWidgets('dugme sa tastaturom otvara pregled prečica', (tester) async {
    await _openApp(tester);
    await tester.tap(find.byTooltip('Prečice na tastaturi (?)'));
    await tester.pumpAndSettle();
    expect(find.text('Prečice na tastaturi'), findsOneWidget);
  });
}
