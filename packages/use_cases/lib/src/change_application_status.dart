import 'package:domain/domain.dart';

import 'application_records.dart';
import 'ports/application_repository.dart';
import 'ports/job_posting_repository.dart';

final class StatusChangeOutcome {
  const StatusChangeOutcome({required this.changed, required this.errors});

  final List<ApplicationRecord> changed;
  final Map<JobApplicationId, DomainError> errors;
}

final class ChangeApplicationStatus {
  const ChangeApplicationStatus({required this.jobs, required this.applications, required this.records});

  final JobPostingRepository jobs;
  final ApplicationRepository applications;
  final ApplicationRecords records;

  Future<StatusChangeOutcome> call({
    required Set<JobApplicationId> ids,
    required ApplicationStatus to,
    required User by,
  }) async {
    final current = await applications.allApplications();
    final postings = {for (final job in await jobs.allJobs()) job.id: job};
    final working = [...current];
    final changed = <JobApplication>[];
    final errors = <JobApplicationId, DomainError>{};
    for (final id in ids) {
      final index = working.indexWhere((a) => a.id == id);
      final job = index < 0 ? null : postings[working[index].jobId];
      if (index < 0 || job == null) {
        errors[id] = const NotFound();
        continue;
      }
      final application = working[index];
      if (!AccessPolicy.canSetStatus(by, application, to)) {
        errors[id] = const NotAllowed();
        continue;
      }
      switch (applyStatusChange(application, to, job: job, applications: working)) {
        case Failure(:final error):
          errors[id] = error;
        case Success(:final value):
          working[index] = value;
          changed.add(value);
      }
    }
    if (changed.isEmpty) return StatusChangeOutcome(changed: const [], errors: errors);
    final saved = await applications.saveApplications(changed);
    return StatusChangeOutcome(changed: await records.of(saved), errors: errors);
  }
}
