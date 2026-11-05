import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

Map<String, Object?> overTheWire(Map<String, Object?> json) => jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  final job = JobPosting(
    id: const JobPostingId('job-1'),
    employerId: const EmployerId('emp-1'),
    employerName: 'Logistika Plus',
    title: 'Radnik u magacinu',
    description: 'Sortiranje i pakovanje robe.',
    city: 'Niš',
    category: JobCategory.warehouse,
    shift: WorkShift.night,
    payType: PayType.daily,
    hourlyRate: 450,
    requiredWorkers: 5,
    startsAt: DateTime.utc(2026, 11, 10, 7),
    postedAt: DateTime.utc(2026, 10, 28),
    hoursPerShift: 9,
    status: JobStatus.closed,
  );

  test('oglas prolazi kroz ugovor nepromenjen', () {
    expect(JobPostingDto.fromJson(overTheWire(job.toDto().toJson())).toDomain(), job);
  });

  test('prijava sa oglasom i kandidatom prolazi kroz ugovor nepromenjena, u svakom stanju', () {
    for (final status in ApplicationStatus.values) {
      final record = ApplicationRecord(
        application: JobApplication(
          id: const JobApplicationId('app-1'),
          jobId: job.id,
          studentId: const UserId('u-1'),
          status: status,
          appliedAt: DateTime.utc(2026, 10, 30, 10),
          letter: MotivationLetter.parse('Imam iskustva sa radom u magacinu 📦').valueOrNull,
        ),
        job: job,
        candidate: const Candidate(
          id: UserId('u-1'),
          fullName: 'Ana Ilić',
          faculty: 'ETF',
          email: 'ana@student.rs',
          phone: '064 123 4567',
        ),
      );
      expect(ApplicationRecordDto.fromJson(overTheWire(record.toDto().toJson())).toDomain(), record);
    }
  });

  test('pismo koje je server već prihvatio čita se i kada se pravilo u međuvremenu promeni', () {
    final dto = ApplicationDto(
      id: 'app-1',
      jobId: 'job-1',
      studentId: 'u-1',
      status: ApplicationStatusDto.pending,
      appliedAt: DateTime.utc(2026, 10, 30),
      letter: 'Kratko pismo.',
    );
    expect(dto.toDomain().letter?.text, 'Kratko pismo.');
  });

  test('nepoznato stanje ili uloga sa novijeg servera je FormatException, ne pad', () {
    expect(() => applicationStatusFromDto('archived'), throwsFormatException);
    expect(() => userRoleFromDto('admin'), throwsFormatException);
    expect(() => JobPostingDto.fromJson({...job.toDto().toJson(), 'shift': 'split'}).toDomain(), throwsFormatException);
  });

  test('korisnik prolazi kroz ugovor nepromenjen', () {
    for (final role in UserRole.values) {
      final user = User(id: const UserId('u-1'), username: 'ana', role: role, firstName: 'Ana', lastName: 'Ilić');
      expect(UserDto.fromJson(overTheWire(user.toDto().toJson())).toDomain(), user);
    }
  });

  test('svaka domenska greška ima kôd i vraća se kao ista greška', () {
    final errors = <DomainError>[
      const LetterTooShort(5, min: 20),
      const LetterTooLong(501, max: 500),
      const JobClosed(),
      const NoSlotsLeft(),
      const AlreadyApplied(),
      const TooManyActive(5),
      const InvalidTransition(from: ApplicationStatus.completed, to: ApplicationStatus.withdrawn),
      const NotAllowed(),
      const NotFound(),
    ];
    for (final error in errors) {
      final problem = ProblemDto.fromJson(overTheWire(error.toProblem().toJson()));
      expect(problem.toDomainError(), error, reason: problem.code);
    }
    expect({for (final error in errors) error.toProblem().code}.length, errors.length);
  });

  test('greška nosi granicu sa servera, pa klijent pokazuje novu granicu i kada je pravilo kod njega staro', () {
    final problem = ProblemDto.fromJson(overTheWire(const LetterTooShort(25, min: 30).toProblem().toJson()));
    expect(problem.toDomainError(), const LetterTooShort(25, min: 30));
  });

  test('nepoznat kôd sa novijeg servera nije domenska greška', () {
    expect(const ProblemDto(status: 409, code: 'job-paused', title: 'Paused').toDomainError(), isNull);
    expect(const ProblemDto(status: 422, code: ErrorCodes.letterTooShort, title: 'x').toDomainError(), isNull);
    expect(
      const ProblemDto(
        status: 409,
        code: ErrorCodes.invalidTransition,
        title: 'x',
        from: 'archived',
        to: 'pending',
      ).toDomainError(),
      isNull,
    );
  });

  test('ishod masovne promene prolazi kroz ugovor', () {
    final outcome = StatusChangeOutcome(
      changed: const [],
      errors: {const JobApplicationId('app-2'): const NoSlotsLeft()},
    );
    final read = StatusChangeOutcomeDto.fromJson(overTheWire(outcome.toDto().toJson())).toDomain();
    expect(read.changed, isEmpty);
    expect(read.errors, {const JobApplicationId('app-2'): const NoSlotsLeft()});
  });
}
