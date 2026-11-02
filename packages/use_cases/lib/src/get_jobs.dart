import 'package:domain/domain.dart';

import 'ports/job_posting_repository.dart';

final class GetJobs {
  const GetJobs({required this.jobs});

  final JobPostingRepository jobs;

  Future<List<JobPosting>> call() => jobs.allJobs();
}
