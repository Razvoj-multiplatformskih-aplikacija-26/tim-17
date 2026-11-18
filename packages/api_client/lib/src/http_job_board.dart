import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpJobBoard implements JobPostingRepository, ApplicationRepository, CandidateRepository {
  HttpJobBoard(this._api);

  final ApiClient _api;
  final Map<JobPostingId, JobPosting> _jobs = {};
  final Map<UserId, Candidate> _candidates = {};

  late final ApplicationRecords records = ApplicationRecords(jobs: _KnownJobs(_jobs), candidates: this);

  @override
  Future<List<JobPosting>> allJobs() async {
    final answer = await _api.get(ApiPaths.jobs);
    final jobs = accepted(
      answer,
      (json) => [for (final item in objects(json)) JobPostingDto.fromJson(item).toDomain()],
    );
    for (final job in jobs) {
      _jobs[job.id] = job;
    }
    return jobs;
  }

  @override
  Future<JobPosting?> findJob(JobPostingId id) async {
    final answer = await _api.get(ApiPaths.job(id.value));
    if (answer case ApiRejected(error: NotFound())) return null;
    final job = accepted(answer, (json) => JobPostingDto.fromJson(object(json)).toDomain());
    return _jobs[job.id] = job;
  }

  @override
  Future<List<JobApplication>> allApplications() async => _applications(await _api.get(ApiPaths.applications));

  @override
  Future<List<JobApplication>> applicationsOf(UserId studentId) async =>
      _applications(await _api.get(ApiPaths.myApplications));

  @override
  Future<List<JobApplication>> applicationsFor(JobPostingId jobId) async => [
    for (final application in _applications(await _api.get(ApiPaths.myApplications)))
      if (application.jobId == jobId) application,
  ];

  @override
  Future<JobApplication?> findApplication(JobApplicationId id) async {
    final answer = await _api.get(ApiPaths.application(id.value));
    if (answer case ApiRejected(error: NotFound())) return null;
    return accepted(answer, _record).application;
  }

  @override
  Future<Result<JobApplication>> createApplication({
    required JobPostingId jobId,
    required UserId studentId,
    required MotivationLetter letter,
    required DateTime appliedAt,
  }) async {
    final body = NewApplicationDto(jobId: jobId.value, letter: letter.text);
    return switch (resultOf(await _api.post(ApiPaths.applications, body: body.toJson()), _record)) {
      Success(:final value) => Success(value.application),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<JobApplication>> saveApplication(JobApplication application, {required ApplicationStatus from}) async {
    final id = application.id.value;
    if (application.status == ApplicationStatus.withdrawn) {
      return switch (resultOf(await _api.post(ApiPaths.withdrawal(id)), _record)) {
        Success(:final value) => Success(value.application),
        Failure(:final error) => Failure(error),
      };
    }
    final body = StatusChangeDto(ids: [id], to: application.status.toDto());
    final answer = await _api.post(ApiPaths.statusChanges, body: body.toJson());
    if (answer case ApiRejected(:final error)) return Failure(error);
    final outcome = accepted(answer, (json) => StatusChangeOutcomeDto.fromJson(object(json)));
    if (outcome.errors.firstOrNull case final error?) {
      return switch (error.problem.toDomainError()) {
        final domainError? => Failure(domainError),
        null => throw RepositoryException('Refused: ${error.problem.code}', failure: RepositoryFailure.refused),
      };
    }
    return Success(_remember(outcome.changed.single.toDomain()).application);
  }

  @override
  Future<List<Candidate>> candidatesWithIds(Set<UserId> ids) async => [for (final id in ids) ?_candidates[id]];

  List<JobApplication> _applications(ApiAnswer answer) =>
      accepted(answer, (json) => [for (final item in objects(json)) _record(item).application]);

  ApplicationRecord _record(Object? json) => _remember(ApplicationRecordDto.fromJson(object(json)).toDomain());

  ApplicationRecord _remember(ApplicationRecord record) {
    _jobs[record.job.id] = record.job;
    _candidates[record.candidate.id] = record.candidate;
    return record;
  }
}

final class _KnownJobs implements JobPostingRepository {
  const _KnownJobs(this._jobs);

  final Map<JobPostingId, JobPosting> _jobs;

  @override
  Future<List<JobPosting>> allJobs() async => [..._jobs.values];

  @override
  Future<JobPosting?> findJob(JobPostingId id) async => _jobs[id];
}
