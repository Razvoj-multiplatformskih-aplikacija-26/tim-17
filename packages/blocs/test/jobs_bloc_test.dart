import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'in_memory_jobs.dart';

void main() {
  InMemoryJobBoard seeded() => InMemoryJobBoard(
    jobs: [
      job('j1', rate: 400, postedDay: 1),
      job('j2', rate: 600, city: 'Niš', postedDay: 3),
      job('full', workers: 1),
    ],
    applications: [application('a1', 'full', status: ApplicationStatus.accepted, by: other)],
  );

  JobsBloc build(InMemoryJobBoard jobs) => JobsBloc(
    getJobs: GetJobs(jobs: jobs),
    applyForJob: ApplyForJob(jobs: jobs, applications: jobs, records: recordsOf(jobs), clock: FixedClock(now)),
    student: student,
  );

  List<String> ids(JobsLoaded state) => [for (final j in state.visible) j.id.value];

  Future<void> loaded(JobsBloc bloc) async {
    bloc.add(const JobsRequested());
    await bloc.stream.firstWhere((s) => s is JobsReady);
  }

  blocTest<JobsBloc, JobsState>(
    'učitava oglase sortirane od najnovijeg',
    build: () => build(seeded()),
    act: (bloc) => bloc.add(const JobsRequested()),
    expect: () => [
      const JobsLoading(),
      isA<JobsLoaded>().having(ids, 'visible', ['j2', 'full', 'j1']),
    ],
  );

  blocTest<JobsBloc, JobsState>(
    'bez oglasa prikazuje prazno stanje',
    build: () => build(InMemoryJobBoard()),
    act: (bloc) => bloc.add(const JobsRequested()),
    expect: () => [const JobsLoading(), isA<JobsEmpty>().having((s) => s.isFiltered, 'filtered', isFalse)],
  );

  blocTest<JobsBloc, JobsState>(
    'greška pa Pokušaj ponovo',
    build: () => build(seeded()..failingRequests = 1),
    act: (bloc) => bloc
      ..add(const JobsRequested())
      ..add(const JobsRetried()),
    expect: () => [const JobsLoading(), isA<JobsFailure>(), const JobsLoading(), isA<JobsLoaded>()],
  );

  blocTest<JobsBloc, JobsState>(
    'filteri i sortiranje su događaji, a prazan rezultat je posebno stanje',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc
        ..add(const JobFiltersChanged(JobFilters(sort: JobSort.payHighest)))
        ..add(const JobFiltersChanged(JobFilters(cities: {'Niš'})))
        ..add(const JobFiltersChanged(JobFilters(cities: {'Subotica'})));
    },
    skip: 2,
    expect: () => [
      isA<JobsLoaded>().having(ids, 'visible', ['j2', 'full', 'j1']),
      isA<JobsLoaded>().having(ids, 'visible', ['j2']),
      isA<JobsEmpty>().having((s) => s.isFiltered, 'filtered', isTrue).having((s) => s.jobs.length, 'all', 3),
    ],
  );

  blocTest<JobsBloc, JobsState>(
    'prijava na oglas javlja uspeh',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(ApplyRequested(const JobPostingId('j1'), letter()));
    },
    skip: 2,
    expect: () => [
      isA<JobsLoaded>().having((s) => s.applyingJobId, 'applying', const JobPostingId('j1')),
      isA<JobsLoaded>()
          .having((s) => s.applyingJobId, 'applying', isNull)
          .having((s) => s.notice, 'notice', isA<ApplicationSubmitted>()),
    ],
  );

  blocTest<JobsBloc, JobsState>(
    'prijava na popunjen oglas vraća grešku iz domena',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(ApplyRequested(const JobPostingId('full'), letter()));
    },
    skip: 3,
    expect: () => [
      isA<JobsLoaded>().having(
        (s) => s.notice,
        'notice',
        const ApplicationRejected(JobPostingId('full'), NoSlotsLeft()),
      ),
    ],
  );

  blocTest<JobsBloc, JobsState>(
    'potvrđeno obaveštenje se briše',
    build: () => build(seeded()),
    act: (bloc) async {
      await loaded(bloc);
      bloc.add(ApplyRequested(const JobPostingId('j1'), letter()));
      await bloc.stream.firstWhere((s) => s is JobsReady && s.notice != null);
      bloc.add(const JobsNoticeAcknowledged());
    },
    skip: 4,
    expect: () => [isA<JobsLoaded>().having((s) => s.notice, 'notice', isNull)],
  );

  test('prekid veze pri prijavi javlja ApplicationFailed', () async {
    final jobs = seeded();
    final bloc = build(jobs)..add(const JobsRequested());
    await bloc.stream.firstWhere((s) => s is JobsLoaded);
    jobs.failingRequests = 1;
    bloc.add(ApplyRequested(const JobPostingId('j1'), letter()));
    final state = await bloc.stream.firstWhere((s) => s is JobsReady && s.notice != null) as JobsReady;
    expect(state.notice, isA<ApplicationFailed>().having((n) => n.cause, 'cause', isA<RepositoryException>()));
    await bloc.close();
  });
}
