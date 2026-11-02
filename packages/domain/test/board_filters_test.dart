import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

ApplicationRecord _record(String id, String name, {String jobId = 'job-1', ApplicationStatus? status, int day = 1}) =>
    ApplicationRecord(
      application: JobApplication(
        id: JobApplicationId(id),
        jobId: JobPostingId(jobId),
        studentId: UserId('u-$id'),
        status: status ?? ApplicationStatus.pending,
        appliedAt: DateTime.utc(2026, 10, day),
      ),
      job: job(id: jobId),
      candidate: Candidate(id: UserId('u-$id'), fullName: name, faculty: '', email: '', phone: ''),
    );

List<String> _ids(List<ApplicationRecord> records) => [for (final r in records) r.id.value];

void main() {
  final records = [
    _record('a', 'Ana Ilić', day: 1),
    _record('b', 'Marko Jović', jobId: 'job-2', status: ApplicationStatus.accepted, day: 3),
    _record('c', 'Jelena Ana', status: ApplicationStatus.rejected, day: 2),
  ];

  test('bez filtera vraća sve, najnovije prvo', () {
    expect(_ids(filterBoard(records, const BoardFilters())), ['b', 'c', 'a']);
  });

  test('pretraga gleda ime kandidata, bez obzira na velika slova', () {
    expect(_ids(filterBoard(records, const BoardFilters(query: 'ANA'))), ['c', 'a']);
  });

  test('filter po oglasu i stanju', () {
    expect(_ids(filterBoard(records, const BoardFilters(jobId: JobPostingId('job-2')))), ['b']);
    expect(_ids(filterBoard(records, const BoardFilters(status: ApplicationStatus.rejected))), ['c']);
  });

  test('brojevi po stanju ne zavise od izabranog stanja', () {
    const filters = BoardFilters(query: 'ana', status: ApplicationStatus.pending);
    final counts = countByStatus(searchBoard(records, filters));
    expect(counts[ApplicationStatus.pending], 1);
    expect(counts[ApplicationStatus.rejected], 1);
    expect(counts[ApplicationStatus.accepted], 0);
  });

  test('copyWith može da obriše oglas i stanje', () {
    const filters = BoardFilters(query: 'x', jobId: JobPostingId('job-1'), status: ApplicationStatus.pending);
    expect(filters.copyWith(jobId: () => null, status: () => null), const BoardFilters(query: 'x'));
  });
}
