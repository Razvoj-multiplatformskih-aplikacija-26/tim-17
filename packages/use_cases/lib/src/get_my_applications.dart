import 'package:domain/domain.dart';

import 'application_records.dart';
import 'ports/application_repository.dart';

final class GetMyApplications {
  const GetMyApplications({required this.applications, required this.records});

  final ApplicationRepository applications;
  final ApplicationRecords records;

  Future<List<ApplicationRecord>> call(User student) async {
    final mine = await applications.applicationsOf(student.id);
    final visible = [
      for (final a in mine)
        if (AccessPolicy.canView(student, a)) a,
    ];
    return newestFirst(await records.of(visible));
  }
}
