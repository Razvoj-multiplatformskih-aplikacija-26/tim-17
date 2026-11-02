part of 'my_applications_bloc.dart';

sealed class MyApplicationsEvent extends Equatable {
  const MyApplicationsEvent();

  @override
  List<Object?> get props => const [];
}

final class MyApplicationsRequested extends MyApplicationsEvent {
  const MyApplicationsRequested();
}

final class MyApplicationsRetried extends MyApplicationsEvent {
  const MyApplicationsRetried();
}

final class MyApplicationsRefreshed extends MyApplicationsEvent {
  const MyApplicationsRefreshed();
}

final class MyApplicationsFilterChanged extends MyApplicationsEvent {
  const MyApplicationsFilterChanged(this.status);

  final ApplicationStatus? status;

  @override
  List<Object?> get props => [status];
}

final class WithdrawRequested extends MyApplicationsEvent {
  const WithdrawRequested(this.id);

  final JobApplicationId id;

  @override
  List<Object?> get props => [id];
}

final class MyApplicationsNoticeAcknowledged extends MyApplicationsEvent {
  const MyApplicationsNoticeAcknowledged();
}
