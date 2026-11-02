part of 'my_applications_bloc.dart';

sealed class MyApplicationsState extends Equatable {
  const MyApplicationsState();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => '$runtimeType';
}

final class MyApplicationsLoading extends MyApplicationsState {
  const MyApplicationsLoading();
}

final class MyApplicationsFailure extends MyApplicationsState {
  const MyApplicationsFailure(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];

  @override
  String toString() => 'MyApplicationsFailure($cause)';
}

final class MyApplicationsEmpty extends MyApplicationsState {
  const MyApplicationsEmpty();
}

final class MyApplicationsLoaded extends MyApplicationsState {
  const MyApplicationsLoaded({required this.applications, this.filter, this.withdrawingId, this.notice});

  final List<ApplicationRecord> applications;
  final ApplicationStatus? filter;
  final JobApplicationId? withdrawingId;
  final MyApplicationsNotice? notice;

  List<ApplicationRecord> get visible => [
    for (final record in applications)
      if (filter == null || record.status == filter) record,
  ];

  int countOf(ApplicationStatus status) => applications.where((r) => r.status == status).length;

  ApplicationRecord? find(JobApplicationId id) => applications.where((r) => r.id == id).firstOrNull;

  bool canWithdraw(ApplicationRecord record) => canTransition(record.status, ApplicationStatus.withdrawn);

  bool get isBusy => withdrawingId != null;

  MyApplicationsLoaded copyWith({
    List<ApplicationRecord>? applications,
    ApplicationStatus? Function()? filter,
    JobApplicationId? Function()? withdrawingId,
    MyApplicationsNotice? Function()? notice,
  }) => MyApplicationsLoaded(
    applications: applications ?? this.applications,
    filter: filter == null ? this.filter : filter(),
    withdrawingId: withdrawingId == null ? this.withdrawingId : withdrawingId(),
    notice: notice == null ? this.notice : notice(),
  );

  @override
  List<Object?> get props => [applications, filter, withdrawingId, notice];

  @override
  String toString() => [
    'MyApplicationsLoaded(${applications.length}',
    if (filter case final status?) ', filter ${status.name}',
    if (withdrawingId case final id?) ', withdrawing ${id.value}',
    if (notice case final notice?) ', ${notice.runtimeType}',
    ')',
  ].join();
}

sealed class MyApplicationsNotice extends Equatable {
  const MyApplicationsNotice();

  @override
  List<Object?> get props => const [];
}

final class ApplicationWithdrawn extends MyApplicationsNotice {
  const ApplicationWithdrawn(this.record);

  final ApplicationRecord record;

  @override
  List<Object?> get props => [record];
}

final class WithdrawRejected extends MyApplicationsNotice {
  const WithdrawRejected(this.error);

  final DomainError error;

  @override
  List<Object?> get props => [error];
}

final class WithdrawFailed extends MyApplicationsNotice {
  const WithdrawFailed(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];
}
