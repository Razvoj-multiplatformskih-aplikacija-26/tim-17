import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

final letter = MotivationLetter.parse('Rado bih radio ovaj posao uz fakultet.').valueOrNull!;

ApiClient clientOver(MockClient server, {TokenStore? tokens}) => ApiClient(
  baseUri: Uri.parse('http://localhost:8080'),
  tokens: tokens,
  httpClient: server,
  keepsSessionInCookie: false,
);

http.Response problemAnswer(ProblemDto problem) =>
    http.Response(jsonEncode(problem.toJson()), problem.status, headers: {'content-type': ProblemDto.mediaType});

Future<Result<JobApplication>> apply(HttpJobBoard board) => board.createApplication(
  jobId: const JobPostingId('job-1'),
  studentId: const UserId('u-student'),
  letter: letter,
  appliedAt: DateTime.utc(2026, 11, 18),
);

void main() {
  test('422 sa servera postaje ista domenska greška kao na klijentu', () async {
    final server = MockClient(
      (request) async => problemAnswer(
        const ProblemDto(status: 422, code: ErrorCodes.letterTooShort, title: 'Too short', value: 5, min: 20),
      ),
    );

    final result = await apply(HttpJobBoard(clientOver(server)));

    expect(result, const Failure<JobApplication>(LetterTooShort(5, min: 20)));
  });

  test('nepoznat kôd postaje ApiRefused i ne obara aplikaciju', () async {
    final server = MockClient(
      (request) async => problemAnswer(const ProblemDto(status: 409, code: 'new-rule', title: 'New rule')),
    );

    final answer = await clientOver(server).post(ApiPaths.applications, body: const {});

    expect(answer, isA<ApiRefused>().having((a) => a.problem.code, 'code', 'new-rule'));
    expect(
      apply(HttpJobBoard(clientOver(server))),
      throwsA(isA<RepositoryException>().having((e) => e.failure, 'failure', RepositoryFailure.refused)),
    );
  });

  test('401 session-expired javlja istek prijave', () async {
    final server = MockClient(
      (request) async =>
          problemAnswer(const ProblemDto(status: 401, code: ErrorCodes.sessionExpired, title: 'Session expired')),
    );
    final api = clientOver(server);
    final expired = expectLater(api.expirations, emits(null));

    await expectLater(
      HttpJobBoard(api).allJobs(),
      throwsA(isA<RepositoryException>().having((e) => e.failure, 'failure', RepositoryFailure.sessionExpired)),
    );
    await expired;
  });

  test('nedostupan server postaje RepositoryException koju ekrani umeju da objasne', () async {
    final server = MockClient((request) async => throw http.ClientException('Connection refused', request.url));

    expect(
      HttpJobBoard(clientOver(server)).allJobs(),
      throwsA(isA<RepositoryException>().having((e) => e.failure, 'failure', RepositoryFailure.unreachable)),
    );
  });

  test('van pregledača token ide kao Authorization: Bearer', () async {
    final tokens = MemoryTokenStore();
    await tokens.write('token-of-nikola');
    final seen = <String?>[];
    final server = MockClient((request) async {
      seen.add(request.headers['Authorization']);
      return http.Response('[]', 200, headers: {'content-type': 'application/json'});
    });

    expect(await HttpJobBoard(clientOver(server, tokens: tokens)).allJobs(), isEmpty);
    expect(seen, ['Bearer token-of-nikola']);
  });

  test('greška iz masovne promene vraća se kao Failure za tu prijavu', () async {
    final server = MockClient((request) async {
      expect(request.url.path, ApiPaths.statusChanges);
      final outcome = const StatusChangeOutcomeDto(
        changed: [],
        errors: [
          StatusChangeErrorDto(
            id: 'app-1',
            problem: ProblemDto(status: 409, code: ErrorCodes.noSlotsLeft, title: 'No slots left'),
          ),
        ],
      );
      return http.Response(jsonEncode(outcome.toJson()), 200, headers: {'content-type': 'application/json'});
    });
    final application = JobApplication(
      id: const JobApplicationId('app-1'),
      jobId: const JobPostingId('job-8'),
      studentId: const UserId('u-ana'),
      status: ApplicationStatus.accepted,
      appliedAt: DateTime.utc(2026, 11, 1),
    );

    final result = await HttpJobBoard(clientOver(server)).saveApplication(application, from: ApplicationStatus.pending);

    expect(result, const Failure<JobApplication>(NoSlotsLeft()));
  });
}
