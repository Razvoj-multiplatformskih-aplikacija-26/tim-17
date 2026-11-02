import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'applications_board_event.dart';
part 'applications_board_state.dart';

final class ApplicationsBoardBloc extends Bloc<ApplicationsBoardEvent, ApplicationsBoardState> {
  ApplicationsBoardBloc({required this.getAllApplications, required this.changeApplicationStatus, required this.staff})
    : super(const BoardLoading()) {
    on<BoardRequested>((event, emit) async {
      emit(const BoardLoading());
      await _load(emit);
    });
    on<BoardRetried>((event, emit) async {
      emit(const BoardLoading());
      await _load(emit);
    });
    on<StatusChangeRequested>(_onStatusChangeRequested);
    on<BoardFiltersChanged>((event, emit) {
      _filters = event.filters;
      final current = state;
      if (current is BoardLoaded) emit(current.copyWith(filters: event.filters, updating: current.updating));
    });
    on<BoardNoticeAcknowledged>((event, emit) {
      final current = state;
      if (current is BoardLoaded && current.notice != null) emit(current.copyWith(notice: () => null));
    });
  }

  final GetAllApplications getAllApplications;
  final ChangeApplicationStatus changeApplicationStatus;
  final User staff;
  BoardFilters _filters = const BoardFilters();

  Future<void> _load(Emitter<ApplicationsBoardState> emit) async {
    final Result<List<ApplicationRecord>> result;
    try {
      result = await getAllApplications(staff);
    } on Exception catch (cause) {
      emit(BoardFailure(cause));
      return;
    }
    switch (result) {
      case Failure(:final error):
        emit(BoardFailure(error));
      case Success(:final value) when value.isEmpty:
        emit(const BoardEmpty());
      case Success(:final value):
        emit(BoardLoaded(records: value, staff: staff, filters: _filters));
    }
  }

  Future<void> _onStatusChangeRequested(StatusChangeRequested event, Emitter<ApplicationsBoardState> emit) async {
    final current = state;
    if (current is! BoardLoaded || current.isBusy) return;
    final targets = {
      for (final id in event.ids)
        if (current.canMove(id, event.to)) id,
    };
    if (targets.isEmpty) {
      emit(current.copyWith(notice: () => StatusChangeSkipped(event.to, event.ids.length)));
      return;
    }
    emit(current.copyWith(updating: targets, notice: () => null));
    final StatusChangeOutcome outcome;
    try {
      outcome = await changeApplicationStatus(ids: targets, to: event.to, by: staff);
    } on Exception catch (cause) {
      emit(current.copyWith(notice: () => StatusChangeFailed(event.to, cause)));
      return;
    }
    final changed = outcome.changed;
    if (changed.isEmpty) {
      final errors = outcome.errors.values;
      emit(
        current.copyWith(
          notice: () => errors.length == 1
              ? StatusChangeRejected(event.to, errors.single)
              : StatusChangeSkipped(event.to, event.ids.length),
        ),
      );
      return;
    }
    final byId = {for (final record in changed) record.id: record};
    emit(
      current.copyWith(
        records: [for (final record in current.records) byId[record.id] ?? record],
        notice: () => StatusChanged(event.to, changed: changed.length, skipped: event.ids.length - changed.length),
      ),
    );
  }
}
