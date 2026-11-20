import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_job_board.dart';
import 'data/fake_sessions.dart';
import 'data/seed.dart';

final class AppDependencies {
  AppDependencies({
    required this.clock,
    required JobPostingRepository jobs,
    required ApplicationRepository applications,
    required CandidateRepository candidates,
    required SessionRepository sessions,
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
       ),
       logIn = LogIn(sessions: sessions),
       restoreSession = RestoreSession(sessions: sessions),
       logOut = LogOut(sessions: sessions),
       sessionExpirations = sessions.expirations;

  factory AppDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    final board = HttpJobBoard(api);
    return AppDependencies(
      clock: clock,
      jobs: board,
      applications: board,
      candidates: board,
      sessions: HttpSessionRepository(api),
    );
  }

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency, bool signedIn = true}) {
    final board = latency == null ? FakeJobBoard(clock: clock) : FakeJobBoard(clock: clock, latency: latency);
    return AppDependencies(
      clock: clock,
      jobs: board,
      applications: board,
      candidates: board,
      sessions: FakeSessions(demoStudent, signedIn: signedIn),
      fakeJobBoard: board,
    );
  }

  static const demoStudent = User(
    id: currentStudentId,
    username: 'student1',
    role: UserRole.student,
    firstName: 'Nikola',
    lastName: 'Petrović',
  );

  final Clock clock;
  final GetJobs getJobs;
  final ApplyForJob applyForJob;
  final GetMyApplications getMyApplications;
  final WithdrawApplication withdrawApplication;
  final LogIn logIn;
  final RestoreSession restoreSession;
  final LogOut logOut;
  final Stream<void> sessionExpirations;
  final FakeJobBoard? fakeJobBoard;
}
