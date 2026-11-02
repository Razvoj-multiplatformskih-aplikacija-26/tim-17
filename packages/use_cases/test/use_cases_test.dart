import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'in_memory_fakes.dart';

void main() {
  late InMemoryJobBoard board;

  setUp(() {
    board = InMemoryJobBoard(
      jobs: [
        job('j1'),
        job('full', workers: 1),
        job('closed', status: JobStatus.closed),
      ],
      applications: [
        application('a1', 'j1', day: 1),
        application('a2', 'full', status: ApplicationStatus.accepted, by: otherStudent, day: 3),
        application('a3', 'j1', status: ApplicationStatus.completed, by: otherStudent, day: 2),
      ],
    );
  });

  ApplyForJob apply() =>
      ApplyForJob(jobs: board, applications: board, records: recordsOf(board), clock: FixedClock(now));

  group('ApplyForJob', () {
    test('pravi prijavu na čekanju i vraća je sa oglasom i kandidatom', () async {
      board.applications.removeWhere((a) => a.id == const JobApplicationId('a1'));
      final record = (await apply()(jobId: const JobPostingId('j1'), by: student, letter: letter())).valueOrNull!;
      expect(record.status, ApplicationStatus.pending);
      expect(record.job.id, const JobPostingId('j1'));
      expect(record.candidate.id, student.id);
      expect(record.application.appliedAt, now);
      expect(board.applications, contains(record.application));
    });

    test('pravila iz domena odlučuju pre upisa', () async {
      Future<Result<ApplicationRecord>> to(String id) =>
          apply()(jobId: JobPostingId(id), by: student, letter: letter());
      expect(await to('j1'), const Failure<ApplicationRecord>(AlreadyApplied()));
      expect(await to('full'), const Failure<ApplicationRecord>(NoSlotsLeft()));
      expect(await to('closed'), const Failure<ApplicationRecord>(JobClosed()));
      expect(await to('nema'), const Failure<ApplicationRecord>(NotFound()));
      expect(board.applications.length, 3);
    });

    test('osoblje ne šalje prijave', () async {
      final result = await apply()(jobId: const JobPostingId('j1'), by: referent, letter: letter());
      expect(result, const Failure<ApplicationRecord>(NotAllowed()));
    });

    test('prekid veze stiže kao izuzetak', () async {
      board.failingRequests = 1;
      expect(
        apply()(jobId: const JobPostingId('j1'), by: student, letter: letter()),
        throwsA(isA<RepositoryException>()),
      );
    });
  });

  group('GetMyApplications', () {
    test('vraća samo prijave studenta, najnovije prvo', () async {
      board.applications.add(application('a4', 'full', day: 9, status: ApplicationStatus.rejected));
      final mine = await GetMyApplications(applications: board, records: recordsOf(board))(student);
      expect([for (final r in mine) r.id.value], ['a4', 'a1']);
    });
  });

  group('WithdrawApplication', () {
    WithdrawApplication withdraw() => WithdrawApplication(applications: board, records: recordsOf(board));

    test('menja stanje u povučena i čuva zapis', () async {
      final record = (await withdraw()(id: const JobApplicationId('a1'), by: student)).valueOrNull!;
      expect(record.status, ApplicationStatus.withdrawn);
      expect(board.applications.length, 3);
      expect(board.applications.first.status, ApplicationStatus.withdrawn);
    });

    test('tuđu prijavu ne može da povuče ni drugi student ni osoblje', () async {
      expect(
        await withdraw()(id: const JobApplicationId('a1'), by: otherStudent),
        const Failure<ApplicationRecord>(NotAllowed()),
      );
      expect(
        await withdraw()(id: const JobApplicationId('a1'), by: referent),
        const Failure<ApplicationRecord>(NotAllowed()),
      );
      expect(board.saves, 0);
    });

    test('završena prijava ne može da se povuče', () async {
      board.applications.add(application('a5', 'closed', status: ApplicationStatus.completed));
      expect(
        await withdraw()(id: const JobApplicationId('a5'), by: student),
        const Failure<ApplicationRecord>(
          InvalidTransition(from: ApplicationStatus.completed, to: ApplicationStatus.withdrawn),
        ),
      );
    });
  });

  group('GetAllApplications', () {
    test('osoblje vidi sve prijave', () async {
      final all = (await GetAllApplications(applications: board, records: recordsOf(board))(referent)).valueOrNull!;
      expect([for (final r in all) r.id.value], ['a2', 'a3', 'a1']);
    });

    test('student ne vidi tablu', () async {
      final result = await GetAllApplications(applications: board, records: recordsOf(board))(student);
      expect(result, const Failure<List<ApplicationRecord>>(NotAllowed()));
    });
  });

  group('ChangeApplicationStatus', () {
    ChangeApplicationStatus change() =>
        ChangeApplicationStatus(jobs: board, applications: board, records: recordsOf(board));

    test('masovna promena čuva dozvoljene i vraća razlog za ostale, u jednom upisu', () async {
      final outcome = await change()(
        ids: {const JobApplicationId('a1'), const JobApplicationId('a3'), const JobApplicationId('nema')},
        to: ApplicationStatus.rejected,
        by: referent,
      );
      expect([for (final r in outcome.changed) r.id.value], ['a1']);
      expect(outcome.errors, {
        const JobApplicationId('a3'): const InvalidTransition(
          from: ApplicationStatus.completed,
          to: ApplicationStatus.rejected,
        ),
        const JobApplicationId('nema'): const NotFound(),
      });
      expect(board.saves, 1);
    });

    test('prihvatanje poštuje slobodna mesta i unutar iste masovne promene', () async {
      board.applications
        ..add(application('b1', 'full', by: student))
        ..removeWhere((a) => a.id == const JobApplicationId('a2'));
      board.applications.add(application('b2', 'full', by: otherStudent));
      final outcome = await change()(
        ids: {const JobApplicationId('b1'), const JobApplicationId('b2')},
        to: ApplicationStatus.accepted,
        by: referent,
      );
      expect([for (final r in outcome.changed) r.id.value], ['b1']);
      expect(outcome.errors, {const JobApplicationId('b2'): const NoSlotsLeft()});
    });

    test('student ne menja statuse preko table', () async {
      final outcome = await change()(ids: {const JobApplicationId('a1')}, to: ApplicationStatus.accepted, by: student);
      expect(outcome.changed, isEmpty);
      expect(outcome.errors, {const JobApplicationId('a1'): const NotAllowed()});
      expect(board.saves, 0);
    });
  });
}
