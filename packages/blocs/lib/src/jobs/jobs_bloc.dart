import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc({required this.getJobs, required this.applyForJob, required this.student}) : super(const JobsLoading()) {
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
  final User student;

  Future<void> _load(Emitter<JobsState> emit) async {
    final filters = state.filters;
    try {
      emit(_ready(await getJobs(), filters));
    } on Exception catch (cause) {
      emit(JobsFailure(cause, filters: filters));
    }
  }

  Future<void> _onApplyRequested(ApplyRequested event, Emitter<JobsState> emit) async {
    final current = state;
    if (current is! JobsReady || current.applyingJobId != null) return;
    emit(_ready(current.jobs, current.filters, applyingJobId: event.jobId));
    final Result<ApplicationRecord> result;
    try {
      result = await applyForJob(jobId: event.jobId, by: student, letter: event.letter);
    } on Exception catch (cause) {
      emit(_ready(current.jobs, current.filters, notice: ApplicationFailed(event.jobId, cause)));
      return;
    }
    emit(
      _ready(
        current.jobs,
        current.filters,
        notice: switch (result) {
          Success(:final value) => ApplicationSubmitted(value),
          Failure(:final error) => ApplicationRejected(event.jobId, error),
        },
      ),
    );
  }

  JobsReady _ready(List<JobPosting> jobs, JobFilters filters, {JobPostingId? applyingJobId, JobsNotice? notice}) {
    final visible = filterAndSortJobs(jobs, filters);
    return visible.isEmpty
        ? JobsEmpty(jobs: jobs, filters: filters, applyingJobId: applyingJobId, notice: notice)
        : JobsLoaded(jobs: jobs, visible: visible, filters: filters, applyingJobId: applyingJobId, notice: notice);
  }
}
