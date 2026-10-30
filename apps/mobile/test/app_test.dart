import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';

Future<void> _openApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    JoblyApp(dependencies: AppDependencies.fake(), themeMode: ThemeMode.light),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('aplikacija se otvara na poslovima i prelazi na moje prijave', (
    tester,
  ) async {
    await _openApp(tester);
    expect(find.text('Oglasi stižu uskoro'), findsOneWidget);
    expect(find.text('0 '), findsNothing);

    await tester.tap(find.text('Moje prijave').last);
    await tester.pumpAndSettle();
    expect(find.text('Još nemaš prijava'), findsOneWidget);
  });

  testWidgets('izbor grada se vidi kao oznaka i može da se ukloni', (
    tester,
  ) async {
    await _openApp(tester);

    await tester.tap(find.text('Grad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novi Sad'));
    await tester.tap(find.text('Gotovo'));
    await tester.pumpAndSettle();

    expect(find.text('Nema oglasa za ovu pretragu'), findsOneWidget);
    expect(find.bySemanticsLabel('Ukloni filter Novi Sad'), findsOneWidget);

    await tester.tap(find.text('Obriši sve'));
    await tester.pumpAndSettle();
    expect(find.text('Oglasi stižu uskoro'), findsOneWidget);
  });

  testWidgets('dodir na kategoriju je bira kao filter', (tester) async {
    await _openApp(tester);

    await tester.tap(find.bySemanticsLabel('Kategorija Prodaja'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Ukloni filter Prodaja'), findsOneWidget);
    expect(find.bySemanticsLabel('Filteri, izabrano 1'), findsOneWidget);
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
    expect(
      Theme.of(tester.element(find.text('Poslovi').last)).brightness,
      Brightness.light,
    );

    await tester.tap(find.byTooltip('Tamna tema'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Poslovi').last)).brightness,
      Brightness.dark,
    );
  });
}
