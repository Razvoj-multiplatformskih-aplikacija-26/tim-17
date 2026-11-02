import 'package:backoffice/data/fake_applications_board.dart';
import 'package:backoffice/dependencies.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:use_cases/use_cases.dart';

void main() {
  final clock = FixedClock(DateTime.utc(2026, 11, 1, 10));

  group('lažni podaci', () {
    late FakeApplicationsBoard board;

    setUp(() => board = FakeApplicationsBoard(clock: clock, latency: Duration.zero));

    test('ima bar 30 prijava različitih kandidata na bar 8 oglasa, u svim stanjima', () async {
      final applications = await board.allApplications();
      expect(applications.length, greaterThanOrEqualTo(30));
      expect({for (final a in applications) a.jobId}.length, greaterThanOrEqualTo(8));
      expect({for (final a in applications) a.studentId}.length, greaterThan(15));
      expect({for (final a in applications) a.status}, ApplicationStatus.values.toSet());
    });

    test('podaci poštuju pravilo slobodnih mesta', () async {
      final applications = await board.allApplications();
      for (final job in await board.allJobs()) {
        expect(filledSlots(job, applications), lessThanOrEqualTo(job.requiredWorkers), reason: job.title);
      }
    });

    test('svaki kandidat iz prijava postoji', () async {
      final ids = {for (final a in await board.allApplications()) a.studentId};
      expect((await board.candidatesWithIds(ids)).length, ids.length);
    });

    test('failNextRequest obara samo sledeći zahtev', () async {
      board.failNextRequest();
      await expectLater(board.allApplications(), throwsA(isA<RepositoryException>()));
      expect(await board.allApplications(), isNotEmpty);
    });
  });

  group('posao osoblja kroz slučajeve korišćenja', () {
    late BackofficeDependencies dependencies;

    setUp(() => dependencies = BackofficeDependencies.fake(clock: clock, latency: Duration.zero));

    Future<StatusChangeOutcome> change(Set<String> ids, ApplicationStatus to) => dependencies.changeApplicationStatus(
      ids: {for (final id in ids) JobApplicationId(id)},
      to: to,
      by: dependencies.staff,
    );

    test('osoblje vidi sve prijave sa oglasom i kandidatom', () async {
      final records = (await dependencies.getAllApplications(dependencies.staff)).valueOrNull!;
      expect(records.length, 35);
      expect(records.first.candidate.fullName, isNotEmpty);
    });

    test('prihvatanje koristi prelaze i slobodna mesta iz domena', () async {
      expect((await change({'app-1'}, ApplicationStatus.accepted)).changed.single.status, ApplicationStatus.accepted);
      expect((await change({'app-23'}, ApplicationStatus.accepted)).errors.values.single, isA<InvalidTransition>());
      expect((await change({'app-35'}, ApplicationStatus.accepted)).errors.values.single, const NoSlotsLeft());
    });

    test('masovna promena menja samo prijave kojima je prelaz dozvoljen', () async {
      final outcome = await change({'app-1', 'app-2', 'app-28'}, ApplicationStatus.rejected);
      expect({for (final r in outcome.changed) r.id.value}, {'app-1', 'app-2'});
      expect(outcome.errors.keys, [const JobApplicationId('app-28')]);
    });

    test('osoblje ne može da povuče prijavu umesto studenta', () async {
      final outcome = await change({'app-1'}, ApplicationStatus.withdrawn);
      expect(outcome.errors.values.single, const NotAllowed());
    });
  });
}
