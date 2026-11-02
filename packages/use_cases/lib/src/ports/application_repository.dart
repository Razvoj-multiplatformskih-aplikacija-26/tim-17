import 'package:domain/domain.dart';

abstract interface class ApplicationRepository {
  Future<List<JobApplication>> allApplications();

  Future<List<JobApplication>> applicationsOf(UserId studentId);

  Future<List<JobApplication>> applicationsFor(JobPostingId jobId);

  Future<JobApplication?> findApplication(JobApplicationId id);

  Future<JobApplication> createApplication({
    required JobPostingId jobId,
    required UserId studentId,
    required MotivationLetter letter,
    required DateTime appliedAt,
  });

  Future<List<JobApplication>> saveApplications(List<JobApplication> applications);
}
