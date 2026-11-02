import 'package:domain/domain.dart';

const student = UserId('u-student');
const otherStudent = UserId('u-drugi');

final now = DateTime.utc(2026, 11, 1, 10);

JobPosting job({String id = 'job-1', int requiredWorkers = 3, JobStatus status = JobStatus.open}) => JobPosting(
  id: JobPostingId(id),
  employerId: const EmployerId('emp-1'),
  employerName: 'Magacin d.o.o.',
  title: 'Radnik u magacinu',
  description: 'Sortiranje i pakovanje robe.',
  city: 'Beograd',
  category: JobCategory.warehouse,
  shift: WorkShift.morning,
  payType: PayType.hourly,
  hourlyRate: 450,
  requiredWorkers: requiredWorkers,
  startsAt: DateTime.utc(2026, 11, 10, 8),
  postedAt: DateTime.utc(2026, 10, 25),
  status: status,
);

var _next = 0;

JobApplication application({
  String jobId = 'job-1',
  UserId studentId = student,
  ApplicationStatus status = ApplicationStatus.pending,
}) => JobApplication(
  id: JobApplicationId('app-${_next++}'),
  jobId: JobPostingId(jobId),
  studentId: studentId,
  status: status,
  appliedAt: DateTime.utc(2026, 10, 30),
);

MotivationLetter letter() => MotivationLetter.parse('Imam iskustva sa radom u magacinu.').valueOrNull!;
