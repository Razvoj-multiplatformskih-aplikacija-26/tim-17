import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('backoffice se otvara na prijavama kandidata', (tester) async {
    await tester.pumpWidget(BackofficeApp(dependencies: BackofficeDependencies.fake()));
    await tester.pumpAndSettle();
    expect(find.text('Prijave kandidata'), findsOneWidget);
  });
}
