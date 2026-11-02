import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_applications_board.dart';

const staffReferent = User(id: UserId('u-referent'), role: UserRole.staff, firstName: 'Nikola', lastName: 'Vasiljević');

final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required this.staff,
    required JobPostingRepository jobs,
    required ApplicationRepository applications,
    required CandidateRepository candidates,
    this.fakeBoard,
  }) : getAllApplications = GetAllApplications(
         applications: applications,
         records: ApplicationRecords(jobs: jobs, candidates: candidates),
       ),
       changeApplicationStatus = ChangeApplicationStatus(
         jobs: jobs,
         applications: applications,
         records: ApplicationRecords(jobs: jobs, candidates: candidates),
       );

  factory BackofficeDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final board = latency == null
        ? FakeApplicationsBoard(clock: clock)
        : FakeApplicationsBoard(clock: clock, latency: latency);
    return BackofficeDependencies(
      clock: clock,
      staff: staffReferent,
      jobs: board,
      applications: board,
      candidates: board,
      fakeBoard: board,
    );
  }

  final Clock clock;
  final User staff;
  final GetAllApplications getAllApplications;
  final ChangeApplicationStatus changeApplicationStatus;
  final FakeApplicationsBoard? fakeBoard;
}
