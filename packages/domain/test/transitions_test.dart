import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const pending = ApplicationStatus.pending;
  const accepted = ApplicationStatus.accepted;
  const rejected = ApplicationStatus.rejected;
  const completed = ApplicationStatus.completed;
  const withdrawn = ApplicationStatus.withdrawn;

  const allowed = {
    (pending, accepted),
    (pending, rejected),
    (pending, withdrawn),
    (accepted, completed),
    (accepted, rejected),
    (accepted, withdrawn),
  };

  group('canTransition', () {
    for (final from in ApplicationStatus.values) {
      for (final to in ApplicationStatus.values) {
        final expected = allowed.contains((from, to));
        test('${from.name} -> ${to.name} je ${expected ? 'dozvoljen' : 'zabranjen'}', () {
          expect(canTransition(from, to), expected);
        });
      }
    }

    test('odbijena, završena i povučena su krajnja stanja', () {
      expect(rejected.isFinal, isTrue);
      expect(completed.isFinal, isTrue);
      expect(withdrawn.isFinal, isTrue);
      expect(pending.isFinal, isFalse);
      expect(accepted.isFinal, isFalse);
    });

    test('aktivne su samo prijave na čekanju i prihvaćene', () {
      expect(
        [
          for (final s in ApplicationStatus.values)
            if (s.isActive) s,
        ],
        [pending, accepted],
      );
    });

    test('allowedTransitions vraća isto što i canTransition', () {
      expect(allowedTransitions(pending), {accepted, rejected, withdrawn});
      expect(allowedTransitions(accepted), {completed, rejected, withdrawn});
      expect(allowedTransitions(completed), isEmpty);
    });
  });

  group('promene statusa', () {
    test('odbijanje prijave na čekanju uspeva', () {
      final result = rejectApplication(application());
      expect(result.valueOrNull?.status, rejected);
    });

    test('završavanje prijave na čekanju vraća InvalidTransition', () {
      expect(
        completeApplication(application()),
        const Failure<JobApplication>(InvalidTransition(from: pending, to: completed)),
      );
    });

    test('završavanje prihvaćene prijave uspeva', () {
      expect(completeApplication(application(status: accepted)).valueOrNull?.status, completed);
    });

    test('povlačenje menja stanje i čuva zapis', () {
      final original = application();
      final result = withdrawApplication(original, by: student).valueOrNull!;
      expect(result.status, withdrawn);
      expect(result.id, original.id);
    });

    test('student ne može da povuče tuđu prijavu', () {
      expect(withdrawApplication(application(), by: otherStudent), const Failure<JobApplication>(NotAllowed()));
    });

    test('povučena prijava ne može ponovo da se povuče', () {
      expect(
        withdrawApplication(application(status: withdrawn), by: student),
        const Failure<JobApplication>(InvalidTransition(from: withdrawn, to: withdrawn)),
      );
    });

    test('prihvatanje uspeva dok ima mesta', () {
      final posting = job(requiredWorkers: 2);
      final others = [application(studentId: otherStudent, status: accepted)];
      final result = acceptApplication(application(), job: posting, applications: others);
      expect(result.valueOrNull?.status, accepted);
    });

    test('prihvatanje kada su sva mesta popunjena vraća NoSlotsLeft', () {
      final posting = job(requiredWorkers: 1);
      final others = [application(studentId: otherStudent, status: accepted)];
      expect(
        acceptApplication(application(), job: posting, applications: others),
        const Failure<JobApplication>(NoSlotsLeft()),
      );
    });

    test('prihvatanje odbijene prijave vraća InvalidTransition', () {
      expect(
        acceptApplication(
          application(status: rejected),
          job: job(),
          applications: const [],
        ),
        const Failure<JobApplication>(InvalidTransition(from: rejected, to: accepted)),
      );
    });

    test('applyStatusChange za prihvatanje proverava mesta', () {
      final posting = job(requiredWorkers: 1);
      final others = [application(studentId: otherStudent, status: accepted)];
      expect(
        applyStatusChange(application(), accepted, job: posting, applications: others),
        const Failure<JobApplication>(NoSlotsLeft()),
      );
      expect(
        applyStatusChange(application(), rejected, job: posting, applications: others).valueOrNull?.status,
        rejected,
      );
    });
  });
}
