import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('remainingSlots', () {
    test('bez prihvaćenih prijava ostaje broj traženih radnika', () {
      expect(remainingSlots(job(requiredWorkers: 3), const []), 3);
    });

    test('mesto zauzimaju prihvaćene i završene prijave na isti oglas', () {
      final applications = [
        application(studentId: otherStudent, status: ApplicationStatus.accepted),
        application(status: ApplicationStatus.completed),
        application(status: ApplicationStatus.pending),
        application(status: ApplicationStatus.rejected),
        application(status: ApplicationStatus.withdrawn),
        application(jobId: 'job-2', status: ApplicationStatus.accepted),
      ];
      expect(remainingSlots(job(requiredWorkers: 3), applications), 1);
    });

    test('nikad nije negativan', () {
      final applications = [
        application(status: ApplicationStatus.accepted),
        application(studentId: otherStudent, status: ApplicationStatus.accepted),
      ];
      expect(remainingSlots(job(requiredWorkers: 1), applications), 0);
    });
  });

  group('canApply', () {
    test('prijava na otvoren oglas sa mestima prolazi', () {
      expect(canApply(job: job(), studentId: student, applications: const []).isSuccess, isTrue);
    });

    test('zatvoren oglas vraća JobClosed', () {
      expect(
        canApply(
          job: job(status: JobStatus.closed),
          studentId: student,
          applications: const [],
        ),
        const Failure<void>(JobClosed()),
      );
    });

    test('poslednje slobodno mesto još može da se dobije', () {
      final applications = [application(studentId: otherStudent, status: ApplicationStatus.accepted)];
      expect(canApply(job: job(requiredWorkers: 2), studentId: student, applications: applications).isSuccess, isTrue);
    });

    test('popunjen oglas vraća NoSlotsLeft', () {
      final applications = [application(studentId: otherStudent, status: ApplicationStatus.accepted)];
      expect(
        canApply(job: job(requiredWorkers: 1), studentId: student, applications: applications),
        const Failure<void>(NoSlotsLeft()),
      );
    });

    test('ponovna prijava na isti oglas vraća AlreadyApplied', () {
      expect(
        canApply(job: job(), studentId: student, applications: [application()]),
        const Failure<void>(AlreadyApplied()),
      );
    });

    test('posle povlačenja student može ponovo da se prijavi', () {
      final applications = [application(status: ApplicationStatus.withdrawn)];
      expect(canApply(job: job(), studentId: student, applications: applications).isSuccess, isTrue);
    });

    test('${maxActiveApplications - 1} aktivnih prijava još dozvoljava novu', () {
      final applications = [for (var i = 0; i < maxActiveApplications - 1; i++) application(jobId: 'drugi-$i')];
      expect(canApply(job: job(), studentId: student, applications: applications).isSuccess, isTrue);
    });

    test('$maxActiveApplications aktivnih prijava vraća TooManyActive', () {
      final applications = [
        for (var i = 0; i < maxActiveApplications; i++)
          application(jobId: 'drugi-$i', status: i.isEven ? ApplicationStatus.pending : ApplicationStatus.accepted),
      ];
      expect(
        canApply(job: job(), studentId: student, applications: applications),
        const Failure<void>(TooManyActive(maxActiveApplications)),
      );
    });

    test('završene, odbijene i povučene prijave se ne broje kao aktivne', () {
      final applications = [
        for (var i = 0; i < maxActiveApplications; i++)
          application(
            jobId: 'drugi-$i',
            status: [ApplicationStatus.completed, ApplicationStatus.rejected, ApplicationStatus.withdrawn][i % 3],
          ),
      ];
      expect(canApply(job: job(), studentId: student, applications: applications).isSuccess, isTrue);
    });

    test('tuđe aktivne prijave se ne broje', () {
      final applications = [
        for (var i = 0; i < maxActiveApplications; i++) application(jobId: 'drugi-$i', studentId: otherStudent),
      ];
      expect(canApply(job: job(), studentId: student, applications: applications).isSuccess, isTrue);
    });
  });

  group('submitApplication', () {
    test('pravi prijavu na čekanju sa pismom', () {
      final result = submitApplication(
        id: const JobApplicationId('nova'),
        job: job(),
        studentId: student,
        letter: letter(),
        applications: const [],
        now: now,
      ).valueOrNull!;
      expect(result.status, ApplicationStatus.pending);
      expect(result.jobId, const JobPostingId('job-1'));
      expect(result.letter, letter());
      expect(result.appliedAt, now);
    });

    test('vraća grešku iz canApply', () {
      final result = submitApplication(
        id: const JobApplicationId('nova'),
        job: job(),
        studentId: student,
        letter: letter(),
        applications: [application()],
        now: now,
      );
      expect(result, const Failure<JobApplication>(AlreadyApplied()));
    });
  });

  group('jednakost po vrednosti', () {
    test('dva ista oglasa su jednaka', () {
      expect(job(), job());
      expect(job().hashCode, job().hashCode);
      expect(job(), isNot(job(requiredWorkers: 9)));
    });

    test('promena statusa daje novu prijavu koja nije jednaka staroj', () {
      final original = application();
      expect(original.copyWith(status: ApplicationStatus.accepted), isNot(original));
      expect(original.copyWith(), original);
    });

    test('dva ista korisnika su jednaka', () {
      const a = User(id: student, role: UserRole.student, firstName: 'Ana', lastName: 'Ilić');
      const b = User(id: student, role: UserRole.student, firstName: 'Ana', lastName: 'Ilić');
      expect(a, b);
    });
  });
}
