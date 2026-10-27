const serbianLatin = 'sr_Latn';

String pluralize(int count, {required String one, required String few, required String many}) {
  final lastDigit = count % 10;
  final lastTwoDigits = count % 100;
  if (lastDigit == 1 && lastTwoDigits != 11) return one;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 12 || lastTwoDigits > 14)) return few;
  return many;
}

String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
