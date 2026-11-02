import 'package:meta/meta.dart';

import '../identifiers.dart';
import 'application_status.dart';
import 'motivation_letter.dart';

@immutable
final class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.studentId,
    required this.status,
    required this.appliedAt,
    this.letter,
  });

  final JobApplicationId id;
  final JobPostingId jobId;
  final UserId studentId;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final MotivationLetter? letter;

  bool get isActive => status.isActive;

  JobApplication copyWith({ApplicationStatus? status}) {
    return JobApplication(
      id: id,
      jobId: jobId,
      studentId: studentId,
      status: status ?? this.status,
      appliedAt: appliedAt,
      letter: letter,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is JobApplication &&
      other.id == id &&
      other.jobId == jobId &&
      other.studentId == studentId &&
      other.status == status &&
      other.appliedAt == appliedAt &&
      other.letter == letter;

  @override
  int get hashCode => Object.hash(id, jobId, studentId, status, appliedAt, letter);

  @override
  String toString() => 'JobApplication($id, $jobId, $studentId, $status)';
}
