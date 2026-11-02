import 'package:domain/domain.dart';

import 'application_records.dart';
import 'clock.dart';
import 'ports/application_repository.dart';
import 'ports/job_posting_repository.dart';

final class ApplyForJob {
  const ApplyForJob({required this.jobs, required this.applications, required this.records, required this.clock});

  final JobPostingRepository jobs;
  final ApplicationRepository applications;
  final ApplicationRecords records;
  final Clock clock;

  Future<Result<ApplicationRecord>> call({
    required JobPostingId jobId,
    required User by,
    required MotivationLetter letter,
  }) async {
    if (!AccessPolicy.canApply(by)) return const Failure(NotAllowed());
    final job = await jobs.findJob(jobId);
    if (job == null) return const Failure(NotFound());
    final relevant = {
      ...await applications.applicationsFor(jobId),
      ...await applications.applicationsOf(by.id),
    }.toList();
    if (canApply(job: job, studentId: by.id, applications: relevant) case Failure(:final error)) {
      return Failure(error);
    }
    final created = await applications.createApplication(
      jobId: jobId,
      studentId: by.id,
      letter: letter,
      appliedAt: clock.now(),
    );
    return Success(await records.one(created));
  }
}
