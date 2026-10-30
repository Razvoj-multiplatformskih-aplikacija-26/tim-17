import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  JobsBloc({required this.jobRepository}) : super(const JobsInitial()) {
    on<JobsRequested>(_onJobsRequested);
  }

  final JobRepository jobRepository;

  Future<void> _onJobsRequested(JobsRequested event, Emitter<JobsState> emit) async {
    emit(const JobsLoadInProgress());

    final result = await jobRepository.getJobPostings();

    switch (result) {
      case Success(:final value):
        emit(JobsLoadSuccess(value));
      case Failure(:final error):
        emit(JobsLoadFailure(error));
    }
  }
}
