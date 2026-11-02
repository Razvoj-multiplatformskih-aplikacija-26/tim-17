part of 'applications_board_bloc.dart';

sealed class ApplicationsBoardState extends Equatable {
  const ApplicationsBoardState();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => '$runtimeType';
}

final class BoardLoading extends ApplicationsBoardState {
  const BoardLoading();
}

final class BoardFailure extends ApplicationsBoardState {
  const BoardFailure(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];

  @override
  String toString() => 'BoardFailure($cause)';
}

final class BoardEmpty extends ApplicationsBoardState {
  const BoardEmpty();
}

final class BoardLoaded extends ApplicationsBoardState {
  BoardLoaded({
    required this.records,
    required this.staff,
    this.filters = const BoardFilters(),
    this.updating = const {},
    this.notice,
  }) : matching = searchBoard(records, filters),
       visible = filterBoard(records, filters);

  final List<ApplicationRecord> records;
  final User staff;
  final BoardFilters filters;
  final Set<JobApplicationId> updating;
  final BoardNotice? notice;
  final List<ApplicationRecord> matching;
  final List<ApplicationRecord> visible;

  bool get isBusy => updating.isNotEmpty;

  Map<ApplicationStatus, int> get counts => countByStatus(matching);

  List<JobPosting> get postings {
    final seen = <JobPostingId>{};
    return [
      for (final record in records)
        if (seen.add(record.job.id)) record.job,
    ];
  }

  ApplicationRecord? find(JobApplicationId id) => records.where((r) => r.id == id).firstOrNull;

  bool canMove(JobApplicationId id, ApplicationStatus to) {
    final record = find(id);
    return record != null && AccessPolicy.mayMove(staff, record.application, to);
  }

  Set<ApplicationStatus> actionsFor(JobApplicationId id) => {
    for (final to in ApplicationStatus.values)
      if (canMove(id, to)) to,
  };

  int remainingSlotsFor(JobPosting job) => remainingSlots(job, [for (final r in records) r.application]);

  BoardLoaded copyWith({
    List<ApplicationRecord>? records,
    BoardFilters? filters,
    Set<JobApplicationId>? updating,
    BoardNotice? Function()? notice,
  }) => BoardLoaded(
    records: records ?? this.records,
    staff: staff,
    filters: filters ?? this.filters,
    updating: updating ?? const {},
    notice: notice == null ? this.notice : notice(),
  );

  @override
  List<Object?> get props => [records, staff, filters, updating, notice];

  @override
  String toString() => [
    'BoardLoaded(${records.length}',
    if (updating.isNotEmpty) ', updating ${updating.length}',
    if (notice case final notice?) ', ${notice.runtimeType}',
    ')',
  ].join();
}

sealed class BoardNotice extends Equatable {
  const BoardNotice(this.to);

  final ApplicationStatus to;

  @override
  List<Object?> get props => [to];
}

final class StatusChanged extends BoardNotice {
  const StatusChanged(super.to, {required this.changed, required this.skipped});

  final int changed;
  final int skipped;

  @override
  List<Object?> get props => [to, changed, skipped];
}

final class StatusChangeSkipped extends BoardNotice {
  const StatusChangeSkipped(super.to, this.count);

  final int count;

  @override
  List<Object?> get props => [to, count];
}

final class StatusChangeRejected extends BoardNotice {
  const StatusChangeRejected(super.to, this.error);

  final DomainError error;

  @override
  List<Object?> get props => [to, error];
}

final class StatusChangeFailed extends BoardNotice {
  const StatusChangeFailed(super.to, this.cause);

  final Object cause;

  @override
  List<Object?> get props => [to, cause];
}
