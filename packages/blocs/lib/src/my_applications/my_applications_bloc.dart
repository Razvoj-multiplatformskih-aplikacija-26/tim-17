import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'my_applications_event.dart';
part 'my_applications_state.dart';

final class MyApplicationsBloc extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  MyApplicationsBloc({required this.getMyApplications, required this.withdrawApplication, this._student})
    : super(const MyApplicationsLoading()) {
    on<MyApplicationsStudentChanged>((event, emit) async {
      _student = event.student;
      emit(const MyApplicationsLoading());
      await _load(emit);
    });
    on<MyApplicationsRequested>((event, emit) async {
      emit(const MyApplicationsLoading());
      await _load(emit);
    });
    on<MyApplicationsRetried>((event, emit) async {
      emit(const MyApplicationsLoading());
      await _load(emit);
    });
    on<MyApplicationsRefreshed>((event, emit) async {
      try {
        await _load(emit);
      } finally {
        event._handled.complete();
      }
    });
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
  User? _student;

  User? get student => _student;

  Future<void> _load(Emitter<MyApplicationsState> emit) async {
    final student = _student;
    if (student == null) return;
    final List<ApplicationRecord> applications;
    try {
      applications = await getMyApplications(student);
    } on Exception catch (cause) {
      if (student == _student) emit(MyApplicationsFailure(cause));
      return;
    }
    if (student != _student) return;
    final filter = switch (state) {
      MyApplicationsLoaded(:final filter) => filter,
      _ => null,
    };
    emit(
      applications.isEmpty
          ? const MyApplicationsEmpty()
          : MyApplicationsLoaded(applications: applications, filter: filter),
    );
  }

  Future<void> _onWithdrawRequested(WithdrawRequested event, Emitter<MyApplicationsState> emit) async {
    final current = state;
    final student = _student;
    if (current is! MyApplicationsLoaded || current.isBusy || student == null) return;
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
        emit(
          current.copyWith(
            applications: await _freshApplicationsOr(student, current.applications),
            notice: () => WithdrawRejected(error),
          ),
        );
    }
  }

  Future<List<ApplicationRecord>> _freshApplicationsOr(User student, List<ApplicationRecord> fallback) async {
    try {
      final fresh = await getMyApplications(student);
      return fresh.isEmpty ? fallback : fresh;
    } on Exception {
      return fallback;
    }
  }
}
