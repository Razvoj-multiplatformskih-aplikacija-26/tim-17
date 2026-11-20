import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;
import 'package:use_cases/use_cases.dart';

import 'http.dart';
import 'notifications.dart';
import 'postgres_job_board.dart';
import 'sessions.dart';

final class JobBoardHandlers {
  JobBoardHandlers({required this.board, required Clock clock, required this.notifications})
    : _records = ApplicationRecords(jobs: board, candidates: board),
      _getJobs = GetJobs(jobs: board),
      _getMyApplications = GetMyApplications(
        applications: board,
        records: ApplicationRecords(jobs: board, candidates: board),
      ),
      _getAllApplications = GetAllApplications(
        applications: board,
        records: ApplicationRecords(jobs: board, candidates: board),
      ),
      _applyForJob = ApplyForJob(
        jobs: board,
        applications: board,
        records: ApplicationRecords(jobs: board, candidates: board),
        clock: clock,
      ),
      _withdrawApplication = WithdrawApplication(
        applications: board,
        records: ApplicationRecords(jobs: board, candidates: board),
      ),
      _changeApplicationStatus = ChangeApplicationStatus(
        jobs: board,
        applications: board,
        records: ApplicationRecords(jobs: board, candidates: board),
      );

  final PostgresJobBoard board;
  final NotificationSender notifications;
  final ApplicationRecords _records;
  final GetJobs _getJobs;
  final GetMyApplications _getMyApplications;
  final GetAllApplications _getAllApplications;
  final ApplyForJob _applyForJob;
  final WithdrawApplication _withdrawApplication;
  final ChangeApplicationStatus _changeApplicationStatus;

  Future<Response> jobs(Request request) async => json(200, [for (final job in await _getJobs()) job.toDto().toJson()]);

  Future<Response> job(Request request) async {
    final job = await board.findJob(JobPostingId(_id(request)));
    if (job == null) return problem(const NotFound());
    return json(200, job.toDto().toJson());
  }

  Future<Response> myApplications(Request request) async =>
      json(200, [for (final record in await _getMyApplications(_actor(request))) record.toDto().toJson()]);

  Future<Response> allApplications(Request request) async => switch (await _getAllApplications(_actor(request))) {
    Success(:final value) => json(200, [for (final record in value) record.toDto().toJson()]),
    Failure(:final error) => problem(error),
  };

  Future<Response> application(Request request) async {
    final application = await board.findApplication(JobApplicationId(_id(request)));
    if (application == null || !AccessPolicy.canView(_actor(request), application)) {
      return problem(const NotFound());
    }
    return json(200, (await _records.one(application)).toDto().toJson());
  }

  Future<Response> apply(Request request) async {
    final actor = _actor(request);
    if (!AccessPolicy.canApply(actor)) return problem(const NotAllowed());
    final body = NewApplicationDto.fromJson(await readObject(request));
    final letter = MotivationLetter.parse(body.letter);
    if (letter case Failure(:final error)) return problem(error);
    final created = await _applyForJob(jobId: JobPostingId(body.jobId), by: actor, letter: letter.valueOrNull!);
    return respond(created, status: 201);
  }

  Future<Response> withdraw(Request request) async =>
      respond(await _withdrawApplication(id: JobApplicationId(_id(request)), by: _actor(request)));

  Future<Response> changeStatus(Request request) async {
    final actor = _actor(request);
    if (!AccessPolicy.canReview(actor)) return problem(const NotAllowed());
    final body = StatusChangeDto.fromJson(await readObject(request));
    final to = applicationStatusFromDto(body.to);
    final outcome = await _changeApplicationStatus(
      ids: {for (final id in body.ids) JobApplicationId(id)},
      to: to,
      by: actor,
    );
    if (to == ApplicationStatus.accepted) {
      for (final record in outcome.changed) {
        await notifications.applicationAccepted(record);
      }
    }
    return json(200, outcome.toDto().toJson());
  }

  User _actor(Request request) => currentSession.get(request).user;

  String _id(Request request) => request.rawPathParameters[#id]!;
}
