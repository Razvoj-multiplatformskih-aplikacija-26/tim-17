import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'my_applications_event.dart';
part 'my_applications_state.dart';

final class MyApplicationsBloc extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  MyApplicationsBloc({required this.getMyApplications, required this.withdrawApplication, required this.student})
    : super(const MyApplicationsLoading()) {
    on<MyApplicationsRequested>((event, emit) async {
      emit(const MyApplicationsLoading());
      await _load(emit);
    });
    on<MyApplicationsRetried>((event, emit) async {
      emit(const MyApplicationsLoading());
      await _load(emit);
    });
    on<MyApplicationsRefreshed>((event, emit) => _load(emit));
    on<MyApplicationsFilterChanged>((event, emit) {
      final current = state;
      if (current is MyApplicationsLoaded) emit(current.copyWith(filter: () => event.status));
    });
    on<WithdrawRequested>(_onWithdrawRequested);
    on<MyApplicationsNoticeAcknowledged>((event, emit) {
      final current = state;
      if (current is MyApplicationsLoaded && current.notice != null) emit(current.copyWith(notice: () => null));
    });
  }

  final GetMyApplications getMyApplications;
  final WithdrawApplication withdrawApplication;
  final User student;

  Future<void> _load(Emitter<MyApplicationsState> emit) async {
    final filter = switch (state) {
      MyApplicationsLoaded(:final filter) => filter,
      _ => null,
    };
    final List<ApplicationRecord> applications;
    try {
      applications = await getMyApplications(student);
    } on Exception catch (cause) {
      emit(MyApplicationsFailure(cause));
      return;
    }
    emit(
      applications.isEmpty
          ? const MyApplicationsEmpty()
          : MyApplicationsLoaded(applications: applications, filter: filter),
    );
  }

  Future<void> _onWithdrawRequested(WithdrawRequested event, Emitter<MyApplicationsState> emit) async {
    final current = state;
    if (current is! MyApplicationsLoaded || current.isBusy) return;
    emit(current.copyWith(withdrawingId: () => event.id, notice: () => null));
    final Result<ApplicationRecord> result;
    try {
      result = await withdrawApplication(id: event.id, by: student);
    } on Exception catch (cause) {
      emit(current.copyWith(notice: () => WithdrawFailed(cause)));
      return;
    }
    switch (result) {
      case Success(:final value):
        emit(
          current.copyWith(
            applications: [for (final record in current.applications) record.id == value.id ? value : record],
            notice: () => ApplicationWithdrawn(value),
          ),
        );
      case Failure(:final error):
        emit(current.copyWith(notice: () => WithdrawRejected(error)));
    }
  }
}
