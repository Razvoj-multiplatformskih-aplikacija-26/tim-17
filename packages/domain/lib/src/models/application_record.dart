import 'package:meta/meta.dart';

import '../identifiers.dart';
import 'application_status.dart';
import 'job_application.dart';
import 'job_posting.dart';

@immutable
final class Candidate {
  const Candidate({
    required this.id,
    required this.fullName,
    required this.faculty,
    required this.email,
    required this.phone,
  });

  final UserId id;
  final String fullName;
  final String faculty;
  final String email;
  final String phone;

  @override
  bool operator ==(Object other) =>
      other is Candidate &&
      other.id == id &&
      other.fullName == fullName &&
      other.faculty == faculty &&
      other.email == email &&
      other.phone == phone;

  @override
  int get hashCode => Object.hash(id, fullName, faculty, email, phone);

  @override
  String toString() => 'Candidate($id, $fullName)';
}

@immutable
final class ApplicationRecord {
  const ApplicationRecord({required this.application, required this.job, required this.candidate});

  final JobApplication application;
  final JobPosting job;
  final Candidate candidate;

  JobApplicationId get id => application.id;

  ApplicationStatus get status => application.status;

  ApplicationRecord withApplication(JobApplication application) =>
      ApplicationRecord(application: application, job: job, candidate: candidate);

  @override
  bool operator ==(Object other) =>
      other is ApplicationRecord &&
      other.application == application &&
      other.job == job &&
      other.candidate == candidate;

  @override
  int get hashCode => Object.hash(application, job, candidate);

  @override
  String toString() => 'ApplicationRecord(${application.id}, ${job.title}, ${candidate.fullName}, $status)';
}
