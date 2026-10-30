import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  test('pluralize bira oblik po srpskim pravilima', () {
    String posao(int n) => pluralize(n, one: 'posao', few: 'posla', many: 'poslova');
    expect([posao(1), posao(3), posao(5), posao(11), posao(21)], ['posao', 'posla', 'poslova', 'poslova', 'posao']);
  });

  testWidgets('FailureView nudi dugme Pokušaj ponovo', (tester) async {
    var retried = false;
    await tester.pumpWidget(MaterialApp(home: FailureView(onRetry: () => retried = true)));
    await tester.tap(find.text('Pokušaj ponovo'));
    expect(retried, isTrue);
  });
}
