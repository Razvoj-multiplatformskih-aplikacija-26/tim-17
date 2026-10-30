import '../identifiers.dart';

enum ApplicationStatus { pending, accepted, rejected, completed }

class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.studentId,
    required this.status,
    required this.appliedAt,
  });

  final JobApplicationId id;
  final JobPostingId jobId;
  final UserId studentId;
  final ApplicationStatus status;
  final DateTime appliedAt;
}
