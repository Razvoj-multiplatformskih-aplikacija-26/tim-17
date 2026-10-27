abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

final class FixedClock implements Clock {
  const FixedClock(this.instant);

  final DateTime instant;

  @override
  DateTime now() => instant.toUtc();
}
