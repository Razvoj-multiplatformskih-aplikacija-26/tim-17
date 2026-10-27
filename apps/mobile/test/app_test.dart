import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';

void main() {
  testWidgets('aplikacija se otvara na poslovima i prelazi na moje prijave', (tester) async {
    await tester.pumpWidget(JoblyApp(dependencies: AppDependencies.fake()));
    await tester.pumpAndSettle();
    expect(find.text('Oglasi stižu uskoro.'), findsOneWidget);

    await tester.tap(find.text('Moje prijave').last);
    await tester.pumpAndSettle();
    expect(find.text('Još nemate prijava.'), findsOneWidget);
  });
}
