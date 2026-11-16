import 'package:domain/domain.dart';
import 'package:test/test.dart';

JobPosting _job(
  String id, {
  String city = 'Beograd',
  WorkShift shift = WorkShift.morning,
  PayType payType = PayType.hourly,
  JobCategory category = JobCategory.retail,
  int rate = 400,
  int hours = 8,
  int postedDay = 1,
  int startDay = 10,
  JobStatus status = JobStatus.open,
  String title = 'Posao',
}) => JobPosting(
  id: JobPostingId(id),
  employerId: const EmployerId('emp'),
  employerName: 'Firma $id',
  title: title,
  description: '',
  city: city,
  category: category,
  shift: shift,
  payType: payType,
  hourlyRate: rate,
  requiredWorkers: 2,
  startsAt: DateTime.utc(2026, 11, startDay),
  postedAt: DateTime.utc(2026, 10, postedDay),
  hoursPerShift: hours,
  status: status,
);

List<String> _ids(List<JobPosting> jobs) => [for (final j in jobs) j.id.value];

void main() {
  final jobs = [
    _job('a', city: 'Niš', rate: 500, hours: 4, postedDay: 3, startDay: 12, title: 'Konobar'),
    _job('b', shift: WorkShift.night, payType: PayType.daily, rate: 450, hours: 10, postedDay: 5, startDay: 8),
    _job('c', category: JobCategory.it, rate: 800, hours: 6, postedDay: 1, startDay: 15),
    _job('d', status: JobStatus.closed, rate: 1000),
  ];

  test('bez filtera prikazuju se svi otvoreni oglasi, najnoviji prvi', () {
    expect(_ids(filterAndSortJobs(jobs, const JobFilters())), ['b', 'a', 'c']);
  });

  test('filteri po gradu, smeni, isplati i kategoriji se kombinuju', () {
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(cities: {'Niš'}))), ['a']);
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(shifts: {WorkShift.night}))), ['b']);
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(payTypes: {PayType.daily}))), ['b']);
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(categories: {JobCategory.it}))), ['c']);
    expect(filterAndSortJobs(jobs, const JobFilters(cities: {'Niš'}, shifts: {WorkShift.night})), isEmpty);
  });

  test('najmanja satnica je uključiva granica', () {
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(minHourlyPay: 500))), ['a', 'c']);
  });

  test('pretraga ne razlikuje velika i mala slova i gleda naziv, poslodavca i grad', () {
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(query: 'KONOBAR'))), ['a']);
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(query: 'firma c'))), ['c']);
    expect(_ids(filterAndSortJobs(jobs, const JobFilters(query: ' niš '))), ['a']);
  });

  test('svako sortiranje ima svoj redosled', () {
    List<String> sorted(JobSort sort) => _ids(filterAndSortJobs(jobs, JobFilters(sort: sort)));
    expect(sorted(JobSort.payHighest), ['c', 'a', 'b']);
    expect(sorted(JobSort.payLowest), ['b', 'a', 'c']);
    expect(sorted(JobSort.dailyHighest), ['c', 'b', 'a']);
    expect(sorted(JobSort.hoursShortest), ['a', 'c', 'b']);
    expect(sorted(JobSort.hoursLongest), ['b', 'c', 'a']);
    expect(sorted(JobSort.startSoonest), ['b', 'a', 'c']);
  });

  test('filteri su jednaki po vrednosti', () {
    expect(const JobFilters(cities: {'Niš', 'Beograd'}), const JobFilters(cities: {'Beograd', 'Niš'}));
    expect(const JobFilters(), isNot(const JobFilters(sort: JobSort.payLowest)));
  });
}
