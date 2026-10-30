import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final class AppDependencies {
  AppDependencies({required this.clock, required this.studentId});

  factory AppDependencies.fake({Clock clock = const SystemClock()}) {
    return AppDependencies(clock: clock, studentId: const UserId('u-student'));
  }

  final Clock clock;
  final UserId studentId;
}
