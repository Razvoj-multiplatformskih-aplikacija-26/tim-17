import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'in_memory_jobs.dart';

void main() {
  InMemoryJobBoard seeded() => InMemoryJobBoard(
    jobs: [job('j1'), job('j2')],
    applications: [
      application('a1', 'j1', day: 1),
      application('a2', 'j2', status: ApplicationStatus.completed, day: 5),
      application('a3', 'j1', by: other),
    ],
  );

  MyApplicationsBloc build(InMemoryJobBoard jobs) => MyApplicationsBloc(
    getMyApplications: GetMyApplications(applications: jobs, records: recordsOf(jobs)),
    withdrawApplication: WithdrawApplication(applications: jobs, records: recordsOf(jobs)),
    student: student,
  );

  Future<void> loaded(MyApplicationsBloc bloc) async {
    bloc.add(const MyApplicationsRequested());
    await bloc.stream.firstWhere((s) => s is MyApplicationsLoaded);
  }

  blocTest<MyApplicationsBloc, MyApplicationsState>(
    'učitava samo prijave studenta, najnovije prvo',
    build: () => build(seeded()),
    act: (bloc) => bloc.add(const MyApplicationsRequested()),
    expect: () => [
      const MyApplicationsLoading(),
      isA<MyApplicationsLoaded>().having((s) => [for (final r in s.applications) r.id.value], 'ids', ['a2', 'a1']),
    ],
  );

  blocTest<MyApplicationsBloc, MyApplicationsState>(
    'bez prijava prikazuje prazno stanje',
    build: () => build(InMemoryJobBoard(jobs: [job('j1')])),
    act: (bloc) => bloc.add(const MyApplicationsRequested()),
    expect: () => [const MyApplicationsLoading(), const MyApplicationsEmpty()],
  );

  blocTest<MyApplicationsBloc, MyApplicationsState>(
    'greška pa Pokušaj ponovo vraća podatke',
    build: () => build(seeded()..failingRequests = 1),
    act: (bloc) => bloc
      ..add(const MyApplicationsRequested())
      ..add(const MyApplicationsRetried()),
    expect: () => [
      const MyApplicationsLoading(),
      isA<MyApplicationsFailure>().having((s) => s.cause, 'cause', isA<RepositoryException>()),
      const MyApplicationsLoading(),
      isA<MyApplicationsLoaded>(),
    ],
  );

  blocTest<MyApplicationsBloc, MyApplicationsState>(
    'filter po stanju menja vidljive prijave',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(const MyApplicationsFilterChanged(ApplicationStatus.completed));
    },
    skip: 2,
    expect: () => [
      isA<MyApplicationsLoaded>().having((s) => s.filter, 'filter', ApplicationStatus.completed).having(
        (s) => [for (final r in s.visible) r.id.value],
        'visible',
        ['a2'],
      ),
    ],
  );

  blocTest<MyApplicationsBloc, MyApplicationsState>(
    'povlačenje označi prijavu u toku, pa joj promeni stanje',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(const WithdrawRequested(JobApplicationId('a1')));
    },
    skip: 2,
    expect: () => [
      isA<MyApplicationsLoaded>().having((s) => s.withdrawingId, 'withdrawing', const JobApplicationId('a1')),
      isA<MyApplicationsLoaded>()
          .having((s) => s.withdrawingId, 'withdrawing', isNull)
          .having((s) => s.find(const JobApplicationId('a1'))?.status, 'status', ApplicationStatus.withdrawn)
          .having((s) => s.applications.length, 'count', 2)
          .having((s) => s.notice, 'notice', isA<ApplicationWithdrawn>()),
    ],
  );

  blocTest<MyApplicationsBloc, MyApplicationsState>(
    'povlačenje završene prijave vraća grešku iz domena',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(const WithdrawRequested(JobApplicationId('a2')));
    },
    skip: 3,
    expect: () => [
      isA<MyApplicationsLoaded>().having(
        (s) => s.notice,
        'notice',
        const WithdrawRejected(InvalidTransition(from: ApplicationStatus.completed, to: ApplicationStatus.withdrawn)),
      ),
    ],
  );

  blocTest<MyApplicationsBloc, MyApplicationsState>(
    'prekid veze pri povlačenju ostavlja podatke i javlja grešku',
    build: () => build(seeded()),
    act: (bloc) async {
      bloc.add(const MyApplicationsRequested());
      await bloc.stream.firstWhere((s) => s is MyApplicationsLoaded);
      (bloc.withdrawApplication.applications as InMemoryJobBoard).failingRequests = 1;
      bloc.add(const WithdrawRequested(JobApplicationId('a1')));
    },
    skip: 3,
    expect: () => [
      isA<MyApplicationsLoaded>()
          .having((s) => s.find(const JobApplicationId('a1'))?.status, 'status', ApplicationStatus.pending)
          .having((s) => s.notice, 'notice', isA<WithdrawFailed>()),
    ],
  );
}
