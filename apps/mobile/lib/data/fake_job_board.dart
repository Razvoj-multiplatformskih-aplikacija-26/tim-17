import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'seed.dart';

final class FakeJobBoard implements JobPostingRepository, ApplicationRepository, CandidateRepository {
  FakeJobBoard({required Clock clock, this.latency = const Duration(milliseconds: 300)})
    : _jobs = seedJobs(clock.now()),
      _applications = seedApplications(clock.now());

  final Duration latency;
  final List<JobPosting> _jobs;
  final List<JobApplication> _applications;
  final Map<UserId, Candidate> _candidates = {for (final c in seedCandidates) c.id: c};
  int failingRequests = 0;
  int emptyResponses = 0;
  int _nextId = 1;

  void failNextRequest() => failingRequests++;

  void answerEmptyNext() => emptyResponses++;

  Future<void> _roundTrip() async {
    await Future<void>.delayed(latency);
    if (failingRequests > 0) {
      failingRequests--;
      throw const RepositoryException('Simulirani prekid veze');
    }
  }

  bool _answersEmpty() {
    if (emptyResponses == 0) return false;
    emptyResponses--;
    return true;
  }

  @override
  Future<List<JobPosting>> allJobs() async {
    await _roundTrip();
    return _answersEmpty() ? const [] : List.unmodifiable(_jobs);
  }

  @override
  Future<JobPosting?> findJob(JobPostingId id) async {
    await _roundTrip();
    return _jobs.where((j) => j.id == id).firstOrNull;
  }

  @override
  Future<List<JobApplication>> allApplications() async {
    await _roundTrip();
    return _answersEmpty() ? const [] : List.unmodifiable(_applications);
  }

  @override
  Future<List<JobApplication>> applicationsOf(UserId studentId) async {
    await _roundTrip();
    if (_answersEmpty()) return const [];
    return [
      for (final a in _applications)
        if (a.studentId == studentId) a,
    ];
  }

  @override
  Future<List<JobApplication>> applicationsFor(JobPostingId jobId) async {
    await _roundTrip();
    return [
      for (final a in _applications)
        if (a.jobId == jobId) a,
    ];
  }

  @override
  Future<JobApplication?> findApplication(JobApplicationId id) async {
    await _roundTrip();
    return _applications.where((a) => a.id == id).firstOrNull;
  }

  @override
  Future<JobApplication> createApplication({
    required JobPostingId jobId,
    required UserId studentId,
    required MotivationLetter letter,
    required DateTime appliedAt,
  }) async {
    await _roundTrip();
    final created = JobApplication(
      id: JobApplicationId('local-${_nextId++}'),
      jobId: jobId,
      studentId: studentId,
      status: ApplicationStatus.pending,
      appliedAt: appliedAt,
      letter: letter,
    );
    _applications.add(created);
    return created;
  }

  @override
  Future<List<JobApplication>> saveApplications(List<JobApplication> applications) async {
    await _roundTrip();
    for (final application in applications) {
      final index = _applications.indexWhere((a) => a.id == application.id);
      if (index >= 0) _applications[index] = application;
    }
    return applications;
  }

  @override
  Future<List<Candidate>> candidatesWithIds(Set<UserId> ids) async => [for (final id in ids) ?_candidates[id]];
}
