import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

const uniqueViolation = '23505';
const onePerJobIndex = 'applications_one_per_job';

const _jobColumns =
    'id, employer_id, employer_name, title, description, city, category, shift, pay_type, hourly_rate, '
    'required_workers, starts_at, posted_at, hours_per_shift, status';

const _applicationColumns = 'id, job_id, student_id, status, applied_at, letter';

final class JobBoardStore {
  const JobBoardStore(this._database);

  final Session _database;

  Future<bool> isEmpty() async {
    final rows = await _database.execute('SELECT count(*) FROM users');
    return rows.single[0] == 0;
  }

  Future<List<JobPosting>> jobs() async {
    final rows = await _database.execute('SELECT $_jobColumns FROM job_postings ORDER BY posted_at DESC');
    return [for (final row in rows) _job(row.toColumnMap())];
  }

  Future<JobPosting?> job(JobPostingId id, {bool lock = false}) async {
    final rows = await _database.execute(
      Sql.named('SELECT $_jobColumns FROM job_postings WHERE id = @id${lock ? ' FOR UPDATE' : ''}'),
      parameters: {'id': id.value},
    );
    return rows.isEmpty ? null : _job(rows.single.toColumnMap());
  }

  Future<bool> lockStudent(UserId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT id FROM users WHERE id = @id FOR UPDATE'),
      parameters: {'id': id.value},
    );
    return rows.isNotEmpty;
  }

  Future<List<JobApplication>> applications() => _applications('true', const {});

  Future<List<JobApplication>> applicationsOf(UserId studentId) =>
      _applications('student_id = @student', {'student': studentId.value});

  Future<List<JobApplication>> applicationsFor(JobPostingId jobId) =>
      _applications('job_id = @job', {'job': jobId.value});

  Future<JobApplication?> application(JobApplicationId id) async {
    final found = await _applications('id = @id', {'id': id.value});
    return found.isEmpty ? null : found.single;
  }

  Future<List<Candidate>> candidates(Set<UserId> ids) async {
    final rows = await _database.execute(
      Sql.named('SELECT id, first_name, last_name, faculty, email, phone FROM users WHERE id = ANY(@ids)'),
      parameters: {
        'ids': TypedValue(Type.textArray, [for (final id in ids) id.value]),
      },
    );
    return [
      for (final [id, first, last, faculty, email, phone] in rows)
        Candidate(
          id: UserId(id! as String),
          fullName: '$first $last',
          faculty: faculty! as String,
          email: email! as String,
          phone: phone! as String,
        ),
    ];
  }

  Future<void> insertJob(JobPosting job) => _database.execute(
    Sql.named('''
      INSERT INTO job_postings ($_jobColumns)
      VALUES (@id, @employerId, @employerName, @title, @description, @city, @category, @shift, @payType, @hourlyRate,
              @requiredWorkers, @startsAt, @postedAt, @hoursPerShift, @status)
    '''),
    parameters: {
      'id': job.id.value,
      'employerId': job.employerId.value,
      'employerName': job.employerName,
      'title': job.title,
      'description': job.description,
      'city': job.city,
      'category': job.category.name,
      'shift': job.shift.name,
      'payType': job.payType.name,
      'hourlyRate': job.hourlyRate,
      'requiredWorkers': job.requiredWorkers,
      'startsAt': job.startsAt.toUtc(),
      'postedAt': job.postedAt.toUtc(),
      'hoursPerShift': job.hoursPerShift,
      'status': job.status.name,
    },
  );

  Future<JobApplication> insertApplication({
    JobApplicationId? id,
    required JobPostingId jobId,
    required UserId studentId,
    required DateTime appliedAt,
    MotivationLetter? letter,
    ApplicationStatus status = ApplicationStatus.pending,
  }) async {
    final rows = await _database.execute(
      Sql.named('''
        INSERT INTO applications (id, job_id, student_id, status, applied_at, letter)
        VALUES (COALESCE(@id, gen_random_uuid()::text), @job, @student, @status, @appliedAt, @letter)
        RETURNING id
      '''),
      parameters: {
        'id': TypedValue(Type.text, id?.value),
        'job': jobId.value,
        'student': studentId.value,
        'status': status.name,
        'appliedAt': appliedAt.toUtc(),
        'letter': letter?.text,
      },
    );
    return JobApplication(
      id: JobApplicationId(rows.single[0]! as String),
      jobId: jobId,
      studentId: studentId,
      status: status,
      appliedAt: appliedAt.toUtc(),
      letter: letter,
    );
  }

  Future<bool> changeStatus(
    JobApplicationId id, {
    required ApplicationStatus from,
    required ApplicationStatus to,
  }) async {
    final result = await _database.execute(
      Sql.named('UPDATE applications SET status = @to WHERE id = @id AND status = @from'),
      parameters: {'id': id.value, 'from': from.name, 'to': to.name},
    );
    return result.affectedRows == 1;
  }

  Future<List<JobApplication>> _applications(String where, Map<String, Object?> parameters) async {
    final rows = await _database.execute(
      Sql.named('SELECT $_applicationColumns FROM applications WHERE $where ORDER BY applied_at DESC'),
      parameters: parameters,
    );
    return [for (final row in rows) _application(row.toColumnMap())];
  }
}

JobPosting _job(Map<String, dynamic> row) => JobPosting(
  id: JobPostingId(row['id'] as String),
  employerId: EmployerId(row['employer_id'] as String),
  employerName: row['employer_name'] as String,
  title: row['title'] as String,
  description: row['description'] as String,
  city: row['city'] as String,
  category: JobCategory.values.byName(row['category'] as String),
  shift: WorkShift.values.byName(row['shift'] as String),
  payType: PayType.values.byName(row['pay_type'] as String),
  hourlyRate: row['hourly_rate'] as int,
  requiredWorkers: row['required_workers'] as int,
  startsAt: (row['starts_at'] as DateTime).toUtc(),
  postedAt: (row['posted_at'] as DateTime).toUtc(),
  hoursPerShift: row['hours_per_shift'] as int,
  status: JobStatus.values.byName(row['status'] as String),
);

JobApplication _application(Map<String, dynamic> row) => JobApplication(
  id: JobApplicationId(row['id'] as String),
  jobId: JobPostingId(row['job_id'] as String),
  studentId: UserId(row['student_id'] as String),
  status: ApplicationStatus.values.byName(row['status'] as String),
  appliedAt: (row['applied_at'] as DateTime).toUtc(),
  letter: switch (row['letter']) {
    final String text => MotivationLetter.stored(text),
    _ => null,
  },
);
