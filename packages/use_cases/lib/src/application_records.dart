import 'package:domain/domain.dart';

import 'ports/candidate_repository.dart';
import 'ports/job_posting_repository.dart';

final class ApplicationRecords {
  const ApplicationRecords({required this.jobs, required this.candidates});

  final JobPostingRepository jobs;
  final CandidateRepository candidates;

  Future<List<ApplicationRecord>> of(List<JobApplication> applications) async {
    if (applications.isEmpty) return const [];
    final postings = {for (final job in await jobs.allJobs()) job.id: job};
    final people = {
      for (final candidate in await candidates.candidatesWithIds({for (final a in applications) a.studentId}))
        candidate.id: candidate,
    };
    return [
      for (final application in applications)
        if ((postings[application.jobId], people[application.studentId]) case (final job?, final candidate?))
          ApplicationRecord(application: application, job: job, candidate: candidate),
    ];
  }

  Future<ApplicationRecord> one(JobApplication application) async => (await of([application])).single;
}

List<ApplicationRecord> newestFirst(List<ApplicationRecord> records) =>
    [...records]..sort((a, b) => b.application.appliedAt.compareTo(a.application.appliedAt));
