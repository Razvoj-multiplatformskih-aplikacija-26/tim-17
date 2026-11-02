import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'in_memory_jobs.dart';

void main() {
  const pending = ApplicationStatus.pending;
  const accepted = ApplicationStatus.accepted;
  const rejected = ApplicationStatus.rejected;
  const completed = ApplicationStatus.completed;

  InMemoryJobBoard seeded() => InMemoryJobBoard(
    jobs: [job('j1', workers: 1), job('j2', workers: 5)],
    applications: [
      application('a1', 'j1'),
      application('a2', 'j1', by: other),
      application('a3', 'j2', status: accepted),
      application('a4', 'j2', status: completed, by: other),
    ],
  );

  ApplicationsBoardBloc build(InMemoryJobBoard jobs) => ApplicationsBoardBloc(
    getAllApplications: GetAllApplications(applications: jobs, records: recordsOf(jobs)),
    changeApplicationStatus: ChangeApplicationStatus(jobs: jobs, applications: jobs, records: recordsOf(jobs)),
    staff: referent,
  );

  ApplicationStatus? statusOf(BoardLoaded s, String id) => s.find(JobApplicationId(id))?.status;

  Future<void> loaded(ApplicationsBoardBloc bloc) async {
    bloc.add(const BoardRequested());
    await bloc.stream.firstWhere((s) => s is BoardLoaded);
  }

  Future<void> settled(ApplicationsBoardBloc bloc) =>
      bloc.stream.firstWhere((s) => s is BoardLoaded && !s.isBusy && s.notice != null);

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'učitava sve prijave',
    build: () => build(seeded()),
    act: (bloc) => bloc.add(const BoardRequested()),
    expect: () => [const BoardLoading(), isA<BoardLoaded>().having((s) => s.records.length, 'count', 4)],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'bez prijava prikazuje prazno stanje',
    build: () => build(InMemoryJobBoard()),
    act: (bloc) => bloc.add(const BoardRequested()),
    expect: () => [const BoardLoading(), const BoardEmpty()],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'greška pa Pokušaj ponovo',
    build: () => build(seeded()..failingRequests = 1),
    act: (bloc) => bloc
      ..add(const BoardRequested())
      ..add(const BoardRetried()),
    expect: () => [const BoardLoading(), isA<BoardFailure>(), const BoardLoading(), isA<BoardLoaded>()],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'prihvatanje jedne prijave',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(StatusChangeRequested.single(const JobApplicationId('a1'), accepted));
    },
    skip: 2,
    expect: () => [
      isA<BoardLoaded>().having((s) => s.updating, 'updating', {const JobApplicationId('a1')}),
      isA<BoardLoaded>()
          .having((s) => statusOf(s, 'a1'), 'a1', accepted)
          .having((s) => s.isBusy, 'busy', isFalse)
          .having((s) => s.notice, 'notice', const StatusChanged(accepted, changed: 1, skipped: 0)),
    ],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'prihvatanje kada je oglas popunjen vraća NoSlotsLeft',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(StatusChangeRequested.single(const JobApplicationId('a1'), accepted));
      await settled(bloc);
      bloc.add(StatusChangeRequested.single(const JobApplicationId('a2'), accepted));
    },
    skip: 5,
    expect: () => [
      isA<BoardLoaded>()
          .having((s) => statusOf(s, 'a2'), 'a2', pending)
          .having((s) => s.notice, 'notice', const StatusChangeRejected(accepted, NoSlotsLeft())),
    ],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'masovna promena preskače prijave kojima prelaz nije dozvoljen',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(
        const StatusChangeRequested({JobApplicationId('a1'), JobApplicationId('a3'), JobApplicationId('a4')}, rejected),
      );
    },
    skip: 2,
    expect: () => [
      isA<BoardLoaded>().having((s) => s.updating, 'updating', {
        const JobApplicationId('a1'),
        const JobApplicationId('a3'),
      }),
      isA<BoardLoaded>()
          .having((s) => statusOf(s, 'a1'), 'a1', rejected)
          .having((s) => statusOf(s, 'a3'), 'a3', rejected)
          .having((s) => statusOf(s, 'a4'), 'a4', completed)
          .having((s) => s.notice, 'notice', const StatusChanged(rejected, changed: 2, skipped: 1)),
    ],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'kada nijedan prelaz nije dozvoljen, repozitorijum se ne zove',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(StatusChangeRequested.single(const JobApplicationId('a4'), accepted));
    },
    skip: 2,
    expect: () => [isA<BoardLoaded>().having((s) => s.notice, 'notice', const StatusChangeSkipped(accepted, 1))],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'prekid veze pri promeni ostavlja stare statuse',
    build: () => build(seeded()),
    act: (bloc) async {
      bloc.add(const BoardRequested());
      await bloc.stream.firstWhere((s) => s is BoardLoaded);
      (bloc.getAllApplications.applications as InMemoryJobBoard).failingRequests = 1;
      bloc.add(StatusChangeRequested.single(const JobApplicationId('a3'), completed));
    },
    skip: 3,
    expect: () => [
      isA<BoardLoaded>()
          .having((s) => statusOf(s, 'a3'), 'a3', accepted)
          .having((s) => s.notice, 'notice', isA<StatusChangeFailed>()),
    ],
  );

  test('preostala mesta računa domen', () async {
    final bloc = build(seeded())..add(const BoardRequested());
    final state = await bloc.stream.firstWhere((s) => s is BoardLoaded) as BoardLoaded;
    expect(state.remainingSlotsFor(job('j2', workers: 5)), 3);
    expect(state.canMove(const JobApplicationId('a1'), accepted), isTrue);
    expect(state.canMove(const JobApplicationId('a4'), accepted), isFalse);
    expect(state.actionsFor(const JobApplicationId('a1')), {accepted, rejected});
    await bloc.close();
  });

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'osoblje ne može da povuče prijavu umesto studenta',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(StatusChangeRequested.single(const JobApplicationId('a1'), ApplicationStatus.withdrawn));
    },
    skip: 2,
    expect: () => [
      isA<BoardLoaded>()
          .having((s) => statusOf(s, 'a1'), 'a1', pending)
          .having((s) => s.notice, 'notice', const StatusChangeSkipped(ApplicationStatus.withdrawn, 1)),
    ],
  );

  blocTest<ApplicationsBoardBloc, ApplicationsBoardState>(
    'filteri su događaj i preživljavaju ponovno učitavanje',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc
        ..add(const BoardFiltersChanged(BoardFilters(status: accepted)))
        ..add(const BoardRequested());
    },
    skip: 1,
    expect: () => [
      isA<BoardLoaded>().having((s) => s.visible.length, 'visible', 4),
      isA<BoardLoaded>()
          .having((s) => [for (final r in s.visible) r.id.value], 'visible', ['a3'])
          .having((s) => s.counts[pending], 'pending', 2),
      const BoardLoading(),
      isA<BoardLoaded>().having((s) => s.filters.status, 'status', accepted),
    ],
  );
}
