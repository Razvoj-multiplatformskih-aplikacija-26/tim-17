part of 'jobs_bloc.dart';

sealed class JobsState extends Equatable {
  const JobsState({this.filters = const JobFilters()});

  final JobFilters filters;

  @override
  List<Object?> get props => [filters];

  @override
  String toString() => '$runtimeType($filters)';
}

final class JobsLoading extends JobsState {
  const JobsLoading({super.filters});
}

final class JobsFailure extends JobsState {
  const JobsFailure(this.cause, {super.filters});

  final Object cause;

  @override
  List<Object?> get props => [cause, filters];

  @override
  String toString() => 'JobsFailure($cause)';
}

sealed class JobsReady extends JobsState {
  const JobsReady({required this.jobs, required super.filters, this.applyingJobId, this.notice});

  final List<JobPosting> jobs;
  final JobPostingId? applyingJobId;
  final JobsNotice? notice;

  JobPosting? find(JobPostingId id) => jobs.where((job) => job.id == id).firstOrNull;

  bool isApplying(JobPostingId id) => applyingJobId == id;

  @override
  List<Object?> get props => [jobs, filters, applyingJobId, notice];
}

final class JobsEmpty extends JobsReady {
  const JobsEmpty({required super.jobs, required super.filters, super.applyingJobId, super.notice});

  bool get isFiltered => filters.isNarrowed;

  @override
  String toString() => 'JobsEmpty(${jobs.length} total, $filters)';
}

final class JobsLoaded extends JobsReady {
  const JobsLoaded({
    required super.jobs,
    required this.visible,
    required super.filters,
    super.applyingJobId,
    super.notice,
  });

  final List<JobPosting> visible;

  @override
  List<Object?> get props => [...super.props, visible];

  @override
  String toString() => [
    'JobsLoaded(${visible.length}/${jobs.length}',
    if (applyingJobId case final id?) ', applying ${id.value}',
    if (notice case final notice?) ', ${notice.runtimeType}',
    ')',
  ].join();
}

sealed class JobsNotice extends Equatable {
  const JobsNotice(this.jobId);

  final JobPostingId jobId;

  @override
  List<Object?> get props => [jobId];
}

final class ApplicationSubmitted extends JobsNotice {
  ApplicationSubmitted(this.record) : super(record.job.id);

  final ApplicationRecord record;

  @override
  List<Object?> get props => [record];
}

final class ApplicationRejected extends JobsNotice {
  const ApplicationRejected(super.jobId, this.error);

  final DomainError error;

  @override
  List<Object?> get props => [jobId, error];
}

final class ApplicationFailed extends JobsNotice {
  const ApplicationFailed(super.jobId, this.cause);

  final Object cause;

  @override
  List<Object?> get props => [jobId, cause];
}
