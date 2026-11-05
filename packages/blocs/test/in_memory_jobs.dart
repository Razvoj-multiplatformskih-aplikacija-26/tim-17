import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

const student = User(
  id: UserId('u-student'),
  username: 'ana',
  role: UserRole.student,
  firstName: 'Ana',
  lastName: 'Ilić',
);
const otherStudent = User(
  id: UserId('u-other'),
  username: 'marko',
  role: UserRole.student,
  firstName: 'Marko',
  lastName: 'Jović',
);
const other = otherStudent;
const referent = User(
  id: UserId('u-ref'),
  username: 'marija',
  role: UserRole.staff,
  firstName: 'Marija',
  lastName: 'Kostić',
);

final now = DateTime.utc(2026, 11, 1, 10);

JobPosting job(
  String id, {
  int workers = 2,
  JobStatus status = JobStatus.open,
  int rate = 400,
  String city = 'Beograd',
  int postedDay = 1,
}) => JobPosting(
  id: JobPostingId(id),
  employerId: const EmployerId('emp'),
  employerName: 'Firma',
  title: 'Posao $id',
  description: '',
  city: city,
  category: JobCategory.retail,
  shift: WorkShift.morning,
  payType: PayType.hourly,
  hourlyRate: rate,
  requiredWorkers: workers,
  startsAt: DateTime.utc(2026, 11, 10),
  postedAt: DateTime.utc(2026, 10, postedDay),
  status: status,
);

JobApplication application(
  String id,
  String jobId, {
  ApplicationStatus status = ApplicationStatus.pending,
  User by = student,
  int day = 1,
}) => JobApplication(
  id: JobApplicationId(id),
  jobId: JobPostingId(jobId),
  studentId: by.id,
  status: status,
  appliedAt: DateTime.utc(2026, 10, day),
);

MotivationLetter letter() => MotivationLetter.parse('Rado bih radio ovaj posao uz fakultet.').valueOrNull!;

final class InMemoryJobBoard implements JobPostingRepository, ApplicationRepository, CandidateRepository {
  InMemoryJobBoard({List<JobPosting> jobs = const [], List<JobApplication> applications = const []})
    : _jobs = [...jobs],
      applications = [...applications];

  final List<JobPosting> _jobs;
  final List<JobApplication> applications;
  int failingRequests = 0;
  int saves = 0;

  Future<void> _roundTrip() async {
    if (failingRequests > 0) {
      failingRequests--;
      throw const RepositoryException('offline');
    }
  }

  @override
  Future<List<JobPosting>> allJobs() async {
    await _roundTrip();
    return [..._jobs];
  }

  @override
  Future<JobPosting?> findJob(JobPostingId id) async {
    await _roundTrip();
    return _jobs.where((j) => j.id == id).firstOrNull;
  }

  @override
  Future<List<JobApplication>> allApplications() async {
    await _roundTrip();
    return [...applications];
  }

  @override
  Future<List<JobApplication>> applicationsOf(UserId studentId) async {
    await _roundTrip();
    return [
      for (final a in applications)
        if (a.studentId == studentId) a,
    ];
  }

  @override
  Future<List<JobApplication>> applicationsFor(JobPostingId jobId) async {
    await _roundTrip();
    return [
      for (final a in applications)
        if (a.jobId == jobId) a,
    ];
  }

  @override
  Future<JobApplication?> findApplication(JobApplicationId id) async {
    await _roundTrip();
    return applications.where((a) => a.id == id).firstOrNull;
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
      id: JobApplicationId('new-${applications.length + 1}'),
      jobId: jobId,
      studentId: studentId,
      status: ApplicationStatus.pending,
      appliedAt: appliedAt,
      letter: letter,
    );
    applications.add(created);
    return created;
  }

  @override
  Future<List<JobApplication>> saveApplications(List<JobApplication> changed) async {
    await _roundTrip();
    saves++;
    for (final a in changed) {
      applications[applications.indexWhere((x) => x.id == a.id)] = a;
    }
    return changed;
  }

  @override
  Future<List<Candidate>> candidatesWithIds(Set<UserId> ids) async => [
    for (final id in ids) Candidate(id: id, fullName: id.value, faculty: '', email: '', phone: ''),
  ];
}

ApplicationRecords recordsOf(InMemoryJobBoard board) => ApplicationRecords(jobs: board, candidates: board);
