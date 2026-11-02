import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/fake_job_board.dart';
import 'package:mobile/data/seed.dart';
import 'package:mobile/dependencies.dart';
import 'package:use_cases/use_cases.dart';

void main() {
  final clock = FixedClock(DateTime.utc(2026, 11, 1, 10));

  MotivationLetter letter() => MotivationLetter.parse('Rado bih radio ovaj posao uz fakultet.').valueOrNull!;

  group('lažni podaci', () {
    late FakeJobBoard board;

    setUp(() => board = FakeJobBoard(clock: clock, latency: Duration.zero));

    test('ima bar deset oglasa i deset prijava studenta u svih pet stanja', () async {
      final mine = await board.applicationsOf(currentStudentId);
      expect((await board.allJobs()).length, greaterThanOrEqualTo(10));
      expect(mine.length, greaterThanOrEqualTo(10));
      expect({for (final a in mine) a.status}, ApplicationStatus.values.toSet());
    });

    test('podaci poštuju pravila iz domena', () async {
      final applications = await board.allApplications();
      for (final job in await board.allJobs()) {
        expect(filledSlots(job, applications), lessThanOrEqualTo(job.requiredWorkers), reason: job.title);
      }
      expect(activeApplicationsOf(currentStudentId, applications), lessThan(maxActiveApplications));
      for (final a in applications) {
        expect(a.letter, isNotNull, reason: a.id.value);
      }
    });

    test('failNextRequest obara samo sledeći zahtev', () async {
      board.failNextRequest();
      await expectLater(board.allJobs(), throwsA(isA<RepositoryException>()));
      expect(await board.allJobs(), isNotEmpty);
    });

    test('answerEmptyNext vraća praznu listu samo jednom', () async {
      board.answerEmptyNext();
      expect(await board.applicationsOf(currentStudentId), isEmpty);
      expect(await board.applicationsOf(currentStudentId), isNotEmpty);
    });

    test('repozitorijum samo čuva, pravila ne proverava', () async {
      final created = await board.createApplication(
        jobId: const JobPostingId('job-1'),
        studentId: currentStudentId,
        letter: letter(),
        appliedAt: clock.now(),
      );
      expect(await board.findApplication(created.id), created);
      await board.saveApplications([created.copyWith(status: ApplicationStatus.withdrawn)]);
      expect((await board.findApplication(created.id))?.status, ApplicationStatus.withdrawn);
    });
  });

  group('ceo tok kroz slučajeve korišćenja', () {
    late AppDependencies dependencies;

    setUp(() => dependencies = AppDependencies.fake(clock: clock, latency: Duration.zero));

    Future<Result<ApplicationRecord>> apply(String jobId) =>
        dependencies.applyForJob(jobId: JobPostingId(jobId), by: dependencies.student, letter: letter());

    test('prijava prolazi kroz pravila iz domena', () async {
      expect(await apply('job-1'), const Failure<ApplicationRecord>(AlreadyApplied()));
      expect(await apply('job-8'), const Failure<ApplicationRecord>(NoSlotsLeft()));
      expect(await apply('job-10'), const Failure<ApplicationRecord>(JobClosed()));

      final created = (await apply('job-12')).valueOrNull!;
      expect(created.status, ApplicationStatus.pending);
      expect(created.job.title, 'Prodavac u knjižari');

      expect(await apply('job-6'), const Failure<ApplicationRecord>(TooManyActive(maxActiveApplications)));
    });

    test('povlačenje menja stanje, a zapis ostaje', () async {
      final before = await dependencies.getMyApplications(dependencies.student);
      final result = await dependencies.withdrawApplication(
        id: const JobApplicationId('app-1'),
        by: dependencies.student,
      );
      expect(result.valueOrNull?.status, ApplicationStatus.withdrawn);
      final after = await dependencies.getMyApplications(dependencies.student);
      expect(after.length, before.length);
    });

    test('student ne može da povuče tuđu prijavu', () async {
      final result = await dependencies.withdrawApplication(
        id: const JobApplicationId('app-11'),
        by: dependencies.student,
      );
      expect(result, const Failure<ApplicationRecord>(NotAllowed()));
    });
  });
}
