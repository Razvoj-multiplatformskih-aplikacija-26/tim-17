import 'package:domain/domain.dart';

import 'ports/job_repository.dart';

final class FakeJobRepository implements JobRepository {
  FakeJobRepository({
    List<JobPosting>? initialJobs,
    List<JobApplication>? initialApplications,
  })  : _jobs = List.of(initialJobs ?? _defaultJobs),
        _applications = List.of(initialApplications ?? []);

  final List<JobPosting> _jobs;
  final List<JobApplication> _applications;

  static const _defaultJobs = [
    JobPosting(
      id: JobPostingId('job-1'),
      employerId: EmployerId('emp-1'),
      title: 'Radnik u magacinu',
      city: 'Beograd',
      hourlyRate: 450.0,
      requiredWorkers: 5,
      status: JobStatus.open,
    ),
    JobPosting(
      id: JobPostingId('job-2'),
      employerId: EmployerId('emp-2'),
      title: 'Promoter / Promoterka',
      city: 'Novi Sad',
      hourlyRate: 500.0,
      requiredWorkers: 2,
      status: JobStatus.open,
    ),
    JobPosting(
      id: JobPostingId('job-3'),
      employerId: EmployerId('emp-1'),
      title: 'Kasir u supermarketu',
      city: 'Beograd',
      hourlyRate: 400.0,
      requiredWorkers: 8,
      status: JobStatus.open,
    ),
  ];

  @override
  Future<Result<List<JobPosting>>> getJobPostings() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Success(List.unmodifiable(_jobs));
  }

  @override
  Future<Result<List<JobApplication>>> getApplicationsForStudent(UserId studentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final studentApps = _applications.where((app) => app.studentId == studentId).toList();
    return Success(List.unmodifiable(studentApps));
  }

  @override
  Future<Result<JobApplication>> applyForJob({
    required JobPostingId jobId,
    required UserId studentId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final jobIndex = _jobs.indexWhere((j) => j.id == jobId);
    if (jobIndex == -1) {
      return const Failure(NotFound());
    }

    final job = _jobs[jobIndex];
    if (job.requiredWorkers <= 0) {
      return const Failure(NotAllowed());
    }

    final application = JobApplication(
      id: JobApplicationId('app-${DateTime.now().millisecondsSinceEpoch}'),
      jobId: jobId,
      studentId: studentId,
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now().toUtc(),
    );

    _applications.add(application);
    return Success(application);
  }

  @override
  Future<Result<void>> cancelApplication(JobApplicationId applicationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) {
      return const Failure(NotFound());
    }
    _applications.removeAt(index);
    return const Success(null);
  }
}