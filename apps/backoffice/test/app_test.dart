import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';

Future<void> _openApp(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    BackofficeApp(
      dependencies: BackofficeDependencies.fake(),
      themeMode: ThemeMode.light,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'širok prozor prikazuje traku sa strane, tabelu i prazno stanje',
    (tester) async {
      await _openApp(tester);
      expect(find.text('Prijave kandidata'), findsOneWidget);
      expect(find.text('Prijave'), findsOneWidget);
      expect(find.text('KANDIDAT'), findsOneWidget);
      expect(find.text('Još nema prijava'), findsOneWidget);
    },
  );

  testWidgets('prečica 2 prebacuje na kanban sa kolonom za svako stanje', (
    tester,
  ) async {
    await _openApp(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pumpAndSettle();
    for (final column in ['Na čekanju', 'Prihvaćene', 'Odbijene', 'Završene']) {
      expect(find.text(column), findsWidgets);
    }
  });

  testWidgets('uzak prozor sklanja traku sa strane', (tester) async {
    await _openApp(tester, size: const Size(700, 900));
    expect(find.text('Prijave kandidata'), findsOneWidget);
    expect(find.text('Referent zadruge'), findsNothing);
    expect(find.text('KANDIDAT'), findsNothing);
  });

  testWidgets('dugme sa tastaturom otvara pregled prečica', (tester) async {
    await _openApp(tester);
    await tester.tap(find.byTooltip('Prečice na tastaturi (?)'));
    await tester.pumpAndSettle();
    expect(find.text('Prečice na tastaturi'), findsOneWidget);
  });
}
