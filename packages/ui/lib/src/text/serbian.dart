const serbianLatin = 'sr_Latn';

String pluralize(int count, {required String one, required String few, required String many}) {
  final lastDigit = count % 10;
  final lastTwoDigits = count % 100;
  if (lastDigit == 1 && lastTwoDigits != 11) return one;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 12 || lastTwoDigits > 14)) return few;
  return many;
}

String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

const _months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'avg', 'sep', 'okt', 'nov', 'dec'];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String formatShortDate(DateTime instant) {
  final local = instant.toLocal();
  return '${local.day}. ${_months[local.month - 1]}';
}

String formatDateTime(DateTime instant) {
  final local = instant.toLocal();
  return '${formatShortDate(local)} u ${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
