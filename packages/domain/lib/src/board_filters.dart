import 'package:meta/meta.dart';

import 'identifiers.dart';
import 'models/application_record.dart';
import 'models/application_status.dart';

@immutable
final class BoardFilters {
  const BoardFilters({this.query = '', this.jobId, this.status});

  final String query;
  final JobPostingId? jobId;
  final ApplicationStatus? status;

  BoardFilters copyWith({String? query, JobPostingId? Function()? jobId, ApplicationStatus? Function()? status}) =>
      BoardFilters(
        query: query ?? this.query,
        jobId: jobId == null ? this.jobId : jobId(),
        status: status == null ? this.status : status(),
      );

  @override
  bool operator ==(Object other) =>
      other is BoardFilters && other.query == query && other.jobId == jobId && other.status == status;

  @override
  int get hashCode => Object.hash(query, jobId, status);

  @override
  String toString() => 'BoardFilters("$query", $jobId, ${status?.name})';
}

bool matchesBoardSearch(ApplicationRecord record, BoardFilters filters) {
  if (filters.jobId != null && record.job.id != filters.jobId) return false;
  final query = filters.query.trim().toLowerCase();
  if (query.isEmpty) return true;
  return record.candidate.fullName.toLowerCase().contains(query) ||
      record.job.title.toLowerCase().contains(query) ||
      record.job.city.toLowerCase().contains(query);
}

List<ApplicationRecord> searchBoard(List<ApplicationRecord> records, BoardFilters filters) =>
    records.where((r) => matchesBoardSearch(r, filters)).toList()
      ..sort((a, b) => b.application.appliedAt.compareTo(a.application.appliedAt));

List<ApplicationRecord> filterBoard(List<ApplicationRecord> records, BoardFilters filters) => [
  for (final record in searchBoard(records, filters))
    if (filters.status == null || record.status == filters.status) record,
];

Map<ApplicationStatus, int> countByStatus(List<ApplicationRecord> records) => {
  for (final status in ApplicationStatus.values) status: records.where((r) => r.status == status).length,
};
