import 'package:domain/domain.dart';
import 'package:domain/domain.dart' as domain;

import 'application_records.dart';
import 'ports/application_repository.dart';

final class WithdrawApplication {
  const WithdrawApplication({required this.applications, required this.records});

  final ApplicationRepository applications;
  final ApplicationRecords records;

  Future<Result<ApplicationRecord>> call({required JobApplicationId id, required User by}) async {
    final application = await applications.findApplication(id);
    if (application == null) return const Failure(NotFound());
    if (!AccessPolicy.canWithdraw(by, application)) return const Failure(NotAllowed());
    switch (domain.withdrawApplication(application, by: by.id)) {
      case Failure(:final error):
        return Failure(error);
      case Success(:final value):
        return switch (await applications.saveApplication(value, from: application.status)) {
          Failure(:final error) => Failure(error),
          Success(:final value) => Success(await records.one(value)),
        };
    }
  }
}
