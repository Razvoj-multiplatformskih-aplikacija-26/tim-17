import 'package:domain/domain.dart';

abstract interface class JobPostingRepository {
  Future<List<JobPosting>> allJobs();

  Future<JobPosting?> findJob(JobPostingId id);
}
