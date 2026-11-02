part of 'jobs_bloc.dart';

sealed class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => const [];
}

final class JobsRequested extends JobsEvent {
  const JobsRequested();
}

final class JobsRetried extends JobsEvent {
  const JobsRetried();
}

final class JobFiltersChanged extends JobsEvent {
  const JobFiltersChanged(this.filters);

  final JobFilters filters;

  @override
  List<Object?> get props => [filters];
}

final class ApplyRequested extends JobsEvent {
  const ApplyRequested(this.jobId, this.letter);

  final JobPostingId jobId;
  final MotivationLetter letter;

  @override
  List<Object?> get props => [jobId, letter];
}

final class JobsNoticeAcknowledged extends JobsEvent {
  const JobsNoticeAcknowledged();
}
