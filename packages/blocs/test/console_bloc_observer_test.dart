import 'package:blocs/blocs.dart';
import 'package:test/test.dart';

void main() {
  test('posmatrač se pravi sa funkcijom za ispis', () {
    final lines = <String>[];
    expect(ConsoleBlocObserver(lines.add), isNotNull);
  });
}
