part of 'jobs_bloc.dart';

sealed class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object> get props => [];
}

final class JobsInitial extends JobsState {
  const JobsInitial();
}

final class JobsLoadInProgress extends JobsState {
  const JobsLoadInProgress();
}

final class JobsLoadSuccess extends JobsState {
  const JobsLoadSuccess(this.jobs);

  final List<JobPosting> jobs;

  @override
  List<Object> get props => [jobs];
}

final class JobsLoadFailure extends JobsState {
  const JobsLoadFailure(this.error);

  final DomainError error;

  @override
  List<Object> get props => [error];
}