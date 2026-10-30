import 'package:domain/domain.dart';

abstract interface class JobRepository {
  Future<Result<List<JobPosting>>> getJobPostings();
  Future<Result<List<JobApplication>>> getApplicationsForStudent(UserId studentId);
  Future<Result<JobApplication>> applyForJob({required JobPostingId jobId, required UserId studentId});
  Future<Result<void>> cancelApplication(JobApplicationId applicationId);
}
