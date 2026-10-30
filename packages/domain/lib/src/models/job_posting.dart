import '../identifiers.dart';

enum JobStatus { open, closed }

class JobPosting {
  const JobPosting({
    required this.id,
    required this.employerId,
    required this.title,
    required this.city,
    required this.hourlyRate,
    required this.requiredWorkers,
    required this.status,
  });

  final JobPostingId id;
  final EmployerId employerId;
  final String title;
  final String city;
  final double hourlyRate;
  final int requiredWorkers;
  final JobStatus status;
}
