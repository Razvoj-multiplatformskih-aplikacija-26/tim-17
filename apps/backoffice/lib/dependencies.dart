import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final class BackofficeDependencies {
  BackofficeDependencies({required this.clock, required this.staffId});

  factory BackofficeDependencies.fake({Clock clock = const SystemClock()}) {
    return BackofficeDependencies(
      clock: clock,
      staffId: const UserId('u-referent'),
    );
  }

  final Clock clock;
  final UserId staffId;
}
