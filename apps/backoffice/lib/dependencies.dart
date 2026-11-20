import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_applications_board.dart';
import 'data/fake_sessions.dart';

const staffReferent = User(
  id: UserId('u-referent'),
  username: 'referent1',
  role: UserRole.staff,
  firstName: 'Nikola',
  lastName: 'Vasiljević',
);

final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required JobPostingRepository jobs,
    required ApplicationRepository applications,
    required CandidateRepository candidates,
    required SessionRepository sessions,
    this.fakeBoard,
  }) : getAllApplications = GetAllApplications(
         applications: applications,
         records: ApplicationRecords(jobs: jobs, candidates: candidates),
       ),
       changeApplicationStatus = ChangeApplicationStatus(
         jobs: jobs,
         applications: applications,
         records: ApplicationRecords(jobs: jobs, candidates: candidates),
       ),
       logIn = LogIn(sessions: sessions),
       restoreSession = RestoreSession(sessions: sessions),
       logOut = LogOut(sessions: sessions),
       sessionExpirations = sessions.expirations;

  factory BackofficeDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    final board = HttpJobBoard(api);
    return BackofficeDependencies(
      clock: clock,
      jobs: board,
      applications: board,
      candidates: board,
      sessions: HttpSessionRepository(api),
    );
  }

  factory BackofficeDependencies.fake({
    Clock clock = const SystemClock(),
    Duration? latency,
    User staff = staffReferent,
    bool signedIn = true,
  }) {
    final board = latency == null
        ? FakeApplicationsBoard(clock: clock)
        : FakeApplicationsBoard(clock: clock, latency: latency);
    return BackofficeDependencies(
      clock: clock,
      jobs: board,
      applications: board,
      candidates: board,
      sessions: FakeSessions(staff, signedIn: signedIn),
      fakeBoard: board,
    );
  }

  final Clock clock;
  final GetAllApplications getAllApplications;
  final ChangeApplicationStatus changeApplicationStatus;
  final LogIn logIn;
  final RestoreSession restoreSession;
  final LogOut logOut;
  final Stream<void> sessionExpirations;
  final FakeApplicationsBoard? fakeBoard;
}
