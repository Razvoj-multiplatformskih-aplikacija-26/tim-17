import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:test/test.dart';

Map<String, Object?> overTheWire(Map<String, Object?> json) => jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  final job = {
    'id': 'job-1',
    'employerId': 'emp-1',
    'employerName': 'Logistika Plus',
    'title': 'Radnik u magacinu',
    'description': 'Sortiranje robe.',
    'city': 'Beograd',
    'category': 'warehouse',
    'shift': 'morning',
    'payType': 'hourly',
    'hourlyRate': 450,
    'requiredWorkers': 5,
    'startsAt': '2026-11-10T07:00:00.000Z',
    'postedAt': '2026-10-28T00:00:00.000Z',
    'hoursPerShift': 8,
    'status': 'open',
  };

  test('stariji klijent čita oglas sa poljem koje još ne zna', () {
    final read = JobPostingDto.fromJson({...job, 'remote': true});
    expect(read.title, 'Radnik u magacinu');
    expect(read.hourlyRate, 450);
    expect(() => JobPostingDto.fromJson({...job}..remove('startsAt')), throwsFormatException);
  });

  test('satnica je ceo broj dinara, a vreme ima vremensku zonu', () {
    expect(() => JobPostingDto.fromJson({...job, 'hourlyRate': 450.5}), throwsFormatException);
    expect(() => JobPostingDto.fromJson({...job, 'startsAt': '2026-11-10T07:00:00'}), throwsFormatException);
    expect(JobPostingDto.fromJson(overTheWire(JobPostingDto.fromJson(job).toJson())).toJson(), job);
  });

  test('greška nosi kôd i granicu pravila', () {
    const problem = ProblemDto(status: 422, code: ErrorCodes.letterTooShort, title: 'Too short', value: 5, min: 20);
    final read = ProblemDto.fromJson(overTheWire(problem.toJson()));
    expect(read.code, ErrorCodes.letterTooShort);
    expect(read.value, 5);
    expect(read.min, 20);
    expect(problem.toJson()['type'], ProblemDto.typeOf(ErrorCodes.letterTooShort));
  });

  test('ishod masovne promene prenosi i promenjene i odbijene prijave', () {
    final record = {
      'application': {
        'id': 'app-1',
        'jobId': 'job-1',
        'studentId': 'u-1',
        'status': ApplicationStatusDto.accepted,
        'appliedAt': '2026-10-30T10:00:00.000Z',
      },
      'job': job,
      'candidate': {'id': 'u-1', 'fullName': 'Ana Ilić', 'faculty': 'ETF', 'email': 'a@b.rs', 'phone': '064'},
    };
    final outcome = StatusChangeOutcomeDto.fromJson(
      overTheWire({
        'changed': [record],
        'errors': [
          {
            'id': 'app-2',
            'problem': const ProblemDto(status: 409, code: ErrorCodes.noSlotsLeft, title: 'No slots').toJson(),
          },
        ],
      }),
    );
    expect(outcome.changed.single.application.status, ApplicationStatusDto.accepted);
    expect(outcome.errors.single.problem.code, ErrorCodes.noSlotsLeft);
  });

  test('zahtev za promenu statusa traži listu tekstualnih id-jeva', () {
    expect(
      StatusChangeDto.fromJson({
        'ids': ['a', 'b'],
        'to': 'rejected',
      }).ids,
      ['a', 'b'],
    );
    expect(
      () => StatusChangeDto.fromJson({
        'ids': [1],
        'to': 'rejected',
      }),
      throwsFormatException,
    );
    expect(() => StatusChangeDto.fromJson({'ids': 'a', 'to': 'rejected'}), throwsFormatException);
  });

  test('sesija nosi token samo kada klijent ne koristi kolačić', () {
    const user = UserDto(id: 'u-1', username: 'student1', role: UserDto.student, firstName: 'Ana', lastName: 'Ilić');
    final withToken = SessionDto(user: user, expiresAt: DateTime.utc(2026, 11, 6), token: 'abc');
    final withoutToken = SessionDto(user: user, expiresAt: DateTime.utc(2026, 11, 6));
    expect(SessionDto.fromJson(overTheWire(withToken.toJson())).token, 'abc');
    expect(withoutToken.toJson().containsKey('token'), isFalse);
    expect(LoginDto.fromJson({'username': 'a', 'password': 'b'}).cookie, isFalse);
  });
}
