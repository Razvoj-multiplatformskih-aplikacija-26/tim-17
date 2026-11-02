part of 'applications_board_bloc.dart';

sealed class ApplicationsBoardEvent extends Equatable {
  const ApplicationsBoardEvent();

  @override
  List<Object?> get props => const [];
}

final class BoardRequested extends ApplicationsBoardEvent {
  const BoardRequested();
}

final class BoardRetried extends ApplicationsBoardEvent {
  const BoardRetried();
}

final class StatusChangeRequested extends ApplicationsBoardEvent {
  const StatusChangeRequested(this.ids, this.to);

  StatusChangeRequested.single(JobApplicationId id, this.to) : ids = {id};

  final Set<JobApplicationId> ids;
  final ApplicationStatus to;

  @override
  List<Object?> get props => [ids, to];
}

final class BoardFiltersChanged extends ApplicationsBoardEvent {
  const BoardFiltersChanged(this.filters);

  final BoardFilters filters;

  @override
  List<Object?> get props => [filters];
}

final class BoardNoticeAcknowledged extends ApplicationsBoardEvent {
  const BoardNoticeAcknowledged();
}
