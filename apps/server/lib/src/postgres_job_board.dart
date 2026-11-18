import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' show Pool, ServerException;
import 'package:use_cases/use_cases.dart';

import 'job_board_store.dart';

final class PostgresJobBoard implements JobPostingRepository, ApplicationRepository, CandidateRepository {
  PostgresJobBoard(this._database) : _store = JobBoardStore(_database);

  final Pool<void> _database;
  final JobBoardStore _store;

  @override
  Future<List<JobPosting>> allJobs() => _store.jobs();

  @override
  Future<JobPosting?> findJob(JobPostingId id) => _store.job(id);

  @override
  Future<List<JobApplication>> allApplications() => _store.applications();

  @override
  Future<List<JobApplication>> applicationsOf(UserId studentId) => _store.applicationsOf(studentId);

  @override
  Future<List<JobApplication>> applicationsFor(JobPostingId jobId) => _store.applicationsFor(jobId);

  @override
  Future<JobApplication?> findApplication(JobApplicationId id) => _store.application(id);

  @override
  Future<List<Candidate>> candidatesWithIds(Set<UserId> ids) => _store.candidates(ids);

  @override
  Future<Result<JobApplication>> createApplication({
    required JobPostingId jobId,
    required UserId studentId,
    required MotivationLetter letter,
    required DateTime appliedAt,
  }) async {
    try {
      return await _database.runTx((session) async {
        final store = JobBoardStore(session);
        if (!await store.lockStudent(studentId)) return const Failure(NotAllowed());
        final job = await store.job(jobId);
        if (job == null) return const Failure(NotFound());
        final relevant = {...await store.applicationsFor(jobId), ...await store.applicationsOf(studentId)}.toList();
        if (canApply(job: job, studentId: studentId, applications: relevant) case Failure(:final error)) {
          return Failure(error);
        }
        return Success(
          await store.insertApplication(jobId: jobId, studentId: studentId, appliedAt: appliedAt, letter: letter),
        );
      });
    } on ServerException catch (error) {
      if (error.code == uniqueViolation && error.constraintName == onePerJobIndex) {
        return const Failure(AlreadyApplied());
      }
      rethrow;
    }
  }

  @override
  Future<Result<JobApplication>> saveApplication(JobApplication application, {required ApplicationStatus from}) {
    if (application.status == ApplicationStatus.accepted) return _accept(application, from: from);
    return _change(application, from: from);
  }

  Future<Result<JobApplication>> _accept(JobApplication application, {required ApplicationStatus from}) =>
      _database.runTx((session) async {
        final store = JobBoardStore(session);
        final job = await store.job(application.jobId, lock: true);
        if (job == null) return const Failure(NotFound());
        final applications = await store.applicationsFor(job.id);
        final current = applications.where((a) => a.id == application.id).firstOrNull;
        if (current == null) return const Failure(NotFound());
        if (current.status != from) return Failure(InvalidTransition(from: current.status, to: application.status));
        switch (acceptApplication(current, job: job, applications: applications)) {
          case Failure(:final error):
            return Failure(error);
          case Success(:final value):
            if (!await store.changeStatus(value.id, from: from, to: value.status)) {
              final latest = await store.application(value.id);
              return Failure(InvalidTransition(from: latest?.status ?? from, to: value.status));
            }
            return Success(value);
        }
      });

  Future<Result<JobApplication>> _change(JobApplication application, {required ApplicationStatus from}) async {
    if (await _store.changeStatus(application.id, from: from, to: application.status)) {
      return Success(application);
    }
    final current = await _store.application(application.id);
    if (current == null) return const Failure(NotFound());
    return Failure(InvalidTransition(from: current.status, to: application.status));
  }
}
