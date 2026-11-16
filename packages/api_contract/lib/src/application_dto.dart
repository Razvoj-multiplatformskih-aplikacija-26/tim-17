import 'job_dto.dart';
import 'json.dart';
import 'problem_dto.dart';

abstract final class ApplicationStatusDto {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const completed = 'completed';
  static const withdrawn = 'withdrawn';
}

final class ApplicationDto {
  const ApplicationDto({
    required this.id,
    required this.jobId,
    required this.studentId,
    required this.status,
    required this.appliedAt,
    this.letter,
  });

  final String id;
  final String jobId;
  final String studentId;
  final String status;
  final DateTime appliedAt;
  final String? letter;

  Map<String, Object?> toJson() => {
    'id': id,
    'jobId': jobId,
    'studentId': studentId,
    'status': status,
    'appliedAt': instantToJson(appliedAt),
    'letter': ?letter,
  };

  factory ApplicationDto.fromJson(Map<String, Object?> json) => ApplicationDto(
    id: jsonString(json, 'id'),
    jobId: jsonString(json, 'jobId'),
    studentId: jsonString(json, 'studentId'),
    status: jsonString(json, 'status'),
    appliedAt: jsonInstant(json, 'appliedAt'),
    letter: jsonOptionalString(json, 'letter'),
  );
}

final class CandidateDto {
  const CandidateDto({
    required this.id,
    required this.fullName,
    required this.faculty,
    required this.email,
    required this.phone,
  });

  final String id;
  final String fullName;
  final String faculty;
  final String email;
  final String phone;

  Map<String, Object?> toJson() => {'id': id, 'fullName': fullName, 'faculty': faculty, 'email': email, 'phone': phone};

  factory CandidateDto.fromJson(Map<String, Object?> json) => CandidateDto(
    id: jsonString(json, 'id'),
    fullName: jsonString(json, 'fullName'),
    faculty: jsonString(json, 'faculty'),
    email: jsonString(json, 'email'),
    phone: jsonString(json, 'phone'),
  );
}

final class ApplicationRecordDto {
  const ApplicationRecordDto({required this.application, required this.job, required this.candidate});

  final ApplicationDto application;
  final JobPostingDto job;
  final CandidateDto candidate;

  Map<String, Object?> toJson() => {
    'application': application.toJson(),
    'job': job.toJson(),
    'candidate': candidate.toJson(),
  };

  factory ApplicationRecordDto.fromJson(Map<String, Object?> json) => ApplicationRecordDto(
    application: ApplicationDto.fromJson(jsonObject(json['application'])),
    job: JobPostingDto.fromJson(jsonObject(json['job'])),
    candidate: CandidateDto.fromJson(jsonObject(json['candidate'])),
  );
}

final class NewApplicationDto {
  const NewApplicationDto({required this.jobId, required this.letter});

  final String jobId;
  final String letter;

  Map<String, Object?> toJson() => {'jobId': jobId, 'letter': letter};

  factory NewApplicationDto.fromJson(Map<String, Object?> json) =>
      NewApplicationDto(jobId: jsonString(json, 'jobId'), letter: jsonString(json, 'letter'));
}

final class StatusChangeDto {
  const StatusChangeDto({required this.ids, required this.to});

  final List<String> ids;
  final String to;

  Map<String, Object?> toJson() => {'ids': ids, 'to': to};

  factory StatusChangeDto.fromJson(Map<String, Object?> json) => StatusChangeDto(
    ids: switch (json['ids']) {
      final List<Object?> ids => [
        for (final id in ids)
          if (id is String) id else throw FormatException('Expected "ids" to hold strings', json),
      ],
      _ => throw FormatException('Expected "ids" to be a list', json),
    },
    to: jsonString(json, 'to'),
  );
}

final class StatusChangeErrorDto {
  const StatusChangeErrorDto({required this.id, required this.problem});

  final String id;
  final ProblemDto problem;

  Map<String, Object?> toJson() => {'id': id, 'problem': problem.toJson()};

  factory StatusChangeErrorDto.fromJson(Map<String, Object?> json) =>
      StatusChangeErrorDto(id: jsonString(json, 'id'), problem: ProblemDto.fromJson(jsonObject(json['problem'])));
}

final class StatusChangeOutcomeDto {
  const StatusChangeOutcomeDto({required this.changed, required this.errors});

  final List<ApplicationRecordDto> changed;
  final List<StatusChangeErrorDto> errors;

  Map<String, Object?> toJson() => {
    'changed': [for (final record in changed) record.toJson()],
    'errors': [for (final error in errors) error.toJson()],
  };

  factory StatusChangeOutcomeDto.fromJson(Map<String, Object?> json) => StatusChangeOutcomeDto(
    changed: [for (final record in jsonObjects(json, 'changed')) ApplicationRecordDto.fromJson(record)],
    errors: [for (final error in jsonObjects(json, 'errors')) StatusChangeErrorDto.fromJson(error)],
  );
}
