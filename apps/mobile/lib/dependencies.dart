import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_job_board.dart';
import 'data/seed.dart';

const currentStudent = User(
  id: currentStudentId,
  username: 'student1',
  role: UserRole.student,
  firstName: 'Nikola',
  lastName: 'Petrović',
);

final class AppDependencies {
  AppDependencies({
    required this.clock,
    required this.student,
    required JobPostingRepository jobs,
    required ApplicationRepository applications,
    required CandidateRepository candidates,
    this.fakeJobBoard,
  }) : getJobs = GetJobs(jobs: jobs),
       applyForJob = ApplyForJob(
         jobs: jobs,
         applications: applications,
         records: ApplicationRecords(jobs: jobs, candidates: candidates),
         clock: clock,
       ),
       getMyApplications = GetMyApplications(
         applications: applications,
         records: ApplicationRecords(jobs: jobs, candidates: candidates),
       ),
       withdrawApplication = WithdrawApplication(
         applications: applications,
         records: ApplicationRecords(jobs: jobs, candidates: candidates),
       );

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final board = latency == null ? FakeJobBoard(clock: clock) : FakeJobBoard(clock: clock, latency: latency);
    return AppDependencies(
      clock: clock,
      student: currentStudent,
      jobs: board,
      applications: board,
      candidates: board,
      fakeJobBoard: board,
    );
  }

  final Clock clock;
  final User student;
  final GetJobs getJobs;
  final ApplyForJob applyForJob;
  final GetMyApplications getMyApplications;
  final WithdrawApplication withdrawApplication;
  final FakeJobBoard? fakeJobBoard;

  UserId get studentId => student.id;
}
