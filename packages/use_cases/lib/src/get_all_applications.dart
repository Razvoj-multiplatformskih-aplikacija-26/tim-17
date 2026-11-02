import 'package:domain/domain.dart';

import 'application_records.dart';
import 'ports/application_repository.dart';

final class GetAllApplications {
  const GetAllApplications({required this.applications, required this.records});

  final ApplicationRepository applications;
  final ApplicationRecords records;

  Future<Result<List<ApplicationRecord>>> call(User by) async {
    if (!AccessPolicy.canReview(by)) return const Failure(NotAllowed());
    return Success(newestFirst(await records.of(await applications.allApplications())));
  }
}
