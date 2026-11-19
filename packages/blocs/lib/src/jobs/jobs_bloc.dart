import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc({required this.getJobs, required this.applyForJob, this._student}) : super(const JobsLoading()) {
    on<JobsStudentChanged>((event, emit) async {
      _student = event.student;
      emit(JobsLoading(filters: state.filters));
      await _load(emit);
    });
    on<JobsRefreshed>((event, emit) async {
      try {
        await _load(emit);
      } finally {
        event._handled.complete();
      }
    });
    on<JobsRequested>((event, emit) async {
      emit(JobsLoading(filters: state.filters));
      await _load(emit);
    });
    on<JobsRetried>((event, emit) async {
      emit(JobsLoading(filters: state.filters));
      await _load(emit);
    });
    on<JobFiltersChanged>((event, emit) {
      final current = state;
      if (current is JobsReady) {
        emit(_ready(current.jobs, event.filters, applyingJobId: current.applyingJobId, notice: current.notice));
      } else {
        emit(switch (current) {
          JobsLoading() => JobsLoading(filters: event.filters),
          JobsFailure(:final cause) => JobsFailure(cause, filters: event.filters),
          JobsReady() => current,
        });
      }
    });
    on<ApplyRequested>(_onApplyRequested);
    on<JobsNoticeAcknowledged>((event, emit) {
      final current = state;
      if (current is JobsReady && current.notice != null) {
        emit(_ready(current.jobs, current.filters, applyingJobId: current.applyingJobId));
      }
    });
  }

  final GetJobs getJobs;
  final ApplyForJob applyForJob;
  User? _student;

  User? get student => _student;

  Future<void> _load(Emitter<JobsState> emit) async {
    final student = _student;
    if (student == null) return;
    try {
      final jobs = await getJobs();
      if (student != _student) return;
      final current = state;
      emit(
        current is JobsReady
            ? _ready(jobs, current.filters, applyingJobId: current.applyingJobId, notice: current.notice)
            : _ready(jobs, current.filters),
      );
    } on Exception catch (cause) {
      if (student == _student) emit(JobsFailure(cause, filters: state.filters));
    }
  }

  Future<void> _onApplyRequested(ApplyRequested event, Emitter<JobsState> emit) async {
    final current = state;
    final student = _student;
    if (current is! JobsReady || current.applyingJobId != null || student == null) return;
    emit(_ready(current.jobs, current.filters, applyingJobId: event.jobId));
    final Result<ApplicationRecord> result;
    try {
      result = await applyForJob(jobId: event.jobId, by: student, letter: event.letter);
    } on Exception catch (cause) {
      emit(_ready(current.jobs, current.filters, notice: ApplicationFailed(event.jobId, cause)));
      return;
    }
    switch (result) {
      case Success(:final value):
        emit(_ready(current.jobs, current.filters, notice: ApplicationSubmitted(value)));
      case Failure(:final error):
        emit(
          _ready(await _freshJobsOr(current.jobs), current.filters, notice: ApplicationRejected(event.jobId, error)),
        );
    }
  }

  Future<List<JobPosting>> _freshJobsOr(List<JobPosting> fallback) async {
    try {
      return await getJobs();
    } on Exception {
      return fallback;
    }
  }

  JobsReady _ready(List<JobPosting> jobs, JobFilters filters, {JobPostingId? applyingJobId, JobsNotice? notice}) {
    final visible = filterAndSortJobs(jobs, filters);
    return visible.isEmpty
        ? JobsEmpty(jobs: jobs, filters: filters, applyingJobId: applyingJobId, notice: notice)
        : JobsLoaded(jobs: jobs, visible: visible, filters: filters, applyingJobId: applyingJobId, notice: notice);
  }
}
