import 'errors.dart';
import 'identifiers.dart';
import 'models/application_status.dart';
import 'models/job_application.dart';
import 'models/job_posting.dart';
import 'models/motivation_letter.dart';
import 'result.dart';

const maxActiveApplications = 5;

bool _holdsSlot(ApplicationStatus status) =>
    status == ApplicationStatus.accepted || status == ApplicationStatus.completed;

int filledSlots(JobPosting job, List<JobApplication> applications) =>
    applications.where((a) => a.jobId == job.id && _holdsSlot(a.status)).length;

int remainingSlots(JobPosting job, List<JobApplication> applications) {
  final left = job.requiredWorkers - filledSlots(job, applications);
  return left < 0 ? 0 : left;
}

int activeApplicationsOf(UserId studentId, List<JobApplication> applications) =>
    applications.where((a) => a.studentId == studentId && a.isActive).length;

bool hasApplied(UserId studentId, JobPostingId jobId, List<JobApplication> applications) =>
    applications.any((a) => a.studentId == studentId && a.jobId == jobId && a.status != ApplicationStatus.withdrawn);

Result<void> canApply({
  required JobPosting job,
  required UserId studentId,
  required List<JobApplication> applications,
}) {
  if (!job.isOpen) return const Failure(JobClosed());
  if (hasApplied(studentId, job.id, applications)) return const Failure(AlreadyApplied());
  if (remainingSlots(job, applications) <= 0) return const Failure(NoSlotsLeft());
  if (activeApplicationsOf(studentId, applications) >= maxActiveApplications) {
    return const Failure(TooManyActive(maxActiveApplications));
  }
  return const Success(null);
}

Result<JobApplication> submitApplication({
  required JobApplicationId id,
  required JobPosting job,
  required UserId studentId,
  required MotivationLetter letter,
  required List<JobApplication> applications,
  required DateTime now,
}) {
  final check = canApply(job: job, studentId: studentId, applications: applications);
  if (check case Failure(:final error)) return Failure(error);
  return Success(
    JobApplication(
      id: id,
      jobId: job.id,
      studentId: studentId,
      status: ApplicationStatus.pending,
      appliedAt: now.toUtc(),
      letter: letter,
    ),
  );
}

Result<JobApplication> changeStatus(JobApplication application, ApplicationStatus to) {
  if (!canTransition(application.status, to)) {
    return Failure(InvalidTransition(from: application.status, to: to));
  }
  return Success(application.copyWith(status: to));
}

Result<JobApplication> acceptApplication(
  JobApplication application, {
  required JobPosting job,
  required List<JobApplication> applications,
}) {
  if (!canTransition(application.status, ApplicationStatus.accepted)) {
    return Failure(InvalidTransition(from: application.status, to: ApplicationStatus.accepted));
  }
  if (remainingSlots(job, applications) <= 0) return const Failure(NoSlotsLeft());
  return Success(application.copyWith(status: ApplicationStatus.accepted));
}

Result<JobApplication> rejectApplication(JobApplication application) =>
    changeStatus(application, ApplicationStatus.rejected);

Result<JobApplication> completeApplication(JobApplication application) =>
    changeStatus(application, ApplicationStatus.completed);

Result<JobApplication> withdrawApplication(JobApplication application, {required UserId by}) {
  if (application.studentId != by) return const Failure(NotAllowed());
  return changeStatus(application, ApplicationStatus.withdrawn);
}

Result<JobApplication> applyStatusChange(
  JobApplication application,
  ApplicationStatus to, {
  required JobPosting job,
  required List<JobApplication> applications,
}) => switch (to) {
  ApplicationStatus.accepted => acceptApplication(application, job: job, applications: applications),
  _ => changeStatus(application, to),
};
