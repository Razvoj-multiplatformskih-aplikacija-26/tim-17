import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'models/job_posting.dart';

enum JobSort { newest, payHighest, payLowest, dailyHighest, hoursShortest, hoursLongest, startSoonest }

const _sets = SetEquality<Object?>();

@immutable
final class JobFilters {
  const JobFilters({
    this.query = '',
    this.cities = const {},
    this.shifts = const {},
    this.payTypes = const {},
    this.categories = const {},
    this.minHourlyPay = 0,
    this.sort = JobSort.newest,
  });

  static const maxHourlyPay = 1500;
  static const hourlyPayStep = 50;

  final String query;
  final Set<String> cities;
  final Set<WorkShift> shifts;
  final Set<PayType> payTypes;
  final Set<JobCategory> categories;
  final int minHourlyPay;
  final JobSort sort;

  int get activeCount =>
      cities.length + shifts.length + payTypes.length + categories.length + (minHourlyPay > 0 ? 1 : 0);

  bool get hasActiveFilters => activeCount > 0;

  bool get isNarrowed => hasActiveFilters || query.trim().isNotEmpty;

  JobFilters copyWith({
    String? query,
    Set<String>? cities,
    Set<WorkShift>? shifts,
    Set<PayType>? payTypes,
    Set<JobCategory>? categories,
    int? minHourlyPay,
    JobSort? sort,
  }) {
    return JobFilters(
      query: query ?? this.query,
      cities: cities ?? this.cities,
      shifts: shifts ?? this.shifts,
      payTypes: payTypes ?? this.payTypes,
      categories: categories ?? this.categories,
      minHourlyPay: minHourlyPay ?? this.minHourlyPay,
      sort: sort ?? this.sort,
    );
  }

  JobFilters cleared() => JobFilters(query: query, sort: sort);

  @override
  bool operator ==(Object other) =>
      other is JobFilters &&
      other.query == query &&
      _sets.equals(other.cities, cities) &&
      _sets.equals(other.shifts, shifts) &&
      _sets.equals(other.payTypes, payTypes) &&
      _sets.equals(other.categories, categories) &&
      other.minHourlyPay == minHourlyPay &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    query,
    _sets.hash(cities),
    _sets.hash(shifts),
    _sets.hash(payTypes),
    _sets.hash(categories),
    minHourlyPay,
    sort,
  );

  @override
  String toString() => 'JobFilters("$query", $activeCount active, ${sort.name})';
}

bool matchesFilters(JobPosting job, JobFilters filters) {
  if (!job.isOpen) return false;
  if (filters.cities.isNotEmpty && !filters.cities.contains(job.city)) return false;
  if (filters.shifts.isNotEmpty && !filters.shifts.contains(job.shift)) return false;
  if (filters.payTypes.isNotEmpty && !filters.payTypes.contains(job.payType)) return false;
  if (filters.categories.isNotEmpty && !filters.categories.contains(job.category)) return false;
  if (job.hourlyRate < filters.minHourlyPay) return false;
  final query = filters.query.trim().toLowerCase();
  if (query.isEmpty) return true;
  return job.title.toLowerCase().contains(query) ||
      job.employerName.toLowerCase().contains(query) ||
      job.city.toLowerCase().contains(query);
}

int Function(JobPosting, JobPosting) _comparator(JobSort sort) => switch (sort) {
  JobSort.newest => (a, b) => b.postedAt.compareTo(a.postedAt),
  JobSort.payHighest => (a, b) => b.hourlyRate.compareTo(a.hourlyRate),
  JobSort.payLowest => (a, b) => a.hourlyRate.compareTo(b.hourlyRate),
  JobSort.dailyHighest => (a, b) => b.dailyPay.compareTo(a.dailyPay),
  JobSort.hoursShortest => (a, b) => a.hoursPerShift.compareTo(b.hoursPerShift),
  JobSort.hoursLongest => (a, b) => b.hoursPerShift.compareTo(a.hoursPerShift),
  JobSort.startSoonest => (a, b) => a.startsAt.compareTo(b.startsAt),
};

List<JobPosting> filterAndSortJobs(List<JobPosting> jobs, JobFilters filters) {
  final compare = _comparator(filters.sort);
  return jobs.where((job) => matchesFilters(job, filters)).toList()..sort((a, b) {
    final byKey = compare(a, b);
    return byKey != 0 ? byKey : a.id.value.compareTo(b.id.value);
  });
}
