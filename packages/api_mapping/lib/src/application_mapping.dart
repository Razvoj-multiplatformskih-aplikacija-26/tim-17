import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'error_mapping.dart';
import 'job_mapping.dart';

extension ApplicationStatusMapping on ApplicationStatus {
  String toDto() => switch (this) {
    ApplicationStatus.pending => ApplicationStatusDto.pending,
    ApplicationStatus.accepted => ApplicationStatusDto.accepted,
    ApplicationStatus.rejected => ApplicationStatusDto.rejected,
    ApplicationStatus.completed => ApplicationStatusDto.completed,
    ApplicationStatus.withdrawn => ApplicationStatusDto.withdrawn,
  };
}

ApplicationStatus applicationStatusFromDto(String status) => switch (status) {
  ApplicationStatusDto.pending => ApplicationStatus.pending,
  ApplicationStatusDto.accepted => ApplicationStatus.accepted,
  ApplicationStatusDto.rejected => ApplicationStatus.rejected,
  ApplicationStatusDto.completed => ApplicationStatus.completed,
  ApplicationStatusDto.withdrawn => ApplicationStatus.withdrawn,
  _ => throw FormatException('Unknown application status "$status"', status),
};

extension JobApplicationMapping on JobApplication {
  ApplicationDto toDto() => ApplicationDto(
    id: id.value,
    jobId: jobId.value,
    studentId: studentId.value,
    status: status.toDto(),
    appliedAt: appliedAt,
    letter: letter?.text,
  );
}

extension ApplicationDtoMapping on ApplicationDto {
  JobApplication toDomain() => JobApplication(
    id: JobApplicationId(id),
    jobId: JobPostingId(jobId),
    studentId: UserId(studentId),
    status: applicationStatusFromDto(status),
    appliedAt: appliedAt,
    letter: switch (letter) {
      final text? => MotivationLetter.stored(text),
      null => null,
    },
  );
}

extension CandidateMapping on Candidate {
  CandidateDto toDto() => CandidateDto(id: id.value, fullName: fullName, faculty: faculty, email: email, phone: phone);
}

extension CandidateDtoMapping on CandidateDto {
  Candidate toDomain() => Candidate(id: UserId(id), fullName: fullName, faculty: faculty, email: email, phone: phone);
}

extension ApplicationRecordMapping on ApplicationRecord {
  ApplicationRecordDto toDto() =>
      ApplicationRecordDto(application: application.toDto(), job: job.toDto(), candidate: candidate.toDto());
}

extension ApplicationRecordDtoMapping on ApplicationRecordDto {
  ApplicationRecord toDomain() =>
      ApplicationRecord(application: application.toDomain(), job: job.toDomain(), candidate: candidate.toDomain());
}

extension StatusChangeOutcomeMapping on StatusChangeOutcome {
  StatusChangeOutcomeDto toDto() => StatusChangeOutcomeDto(
    changed: [for (final record in changed) record.toDto()],
    errors: [
      for (final MapEntry(:key, :value) in errors.entries)
        StatusChangeErrorDto(id: key.value, problem: value.toProblem()),
    ],
  );
}

extension StatusChangeOutcomeDtoMapping on StatusChangeOutcomeDto {
  StatusChangeOutcome toDomain() => StatusChangeOutcome(
    changed: [for (final record in changed) record.toDomain()],
    errors: {for (final error in errors) JobApplicationId(error.id): ?error.problem.toDomainError()},
  );
}
