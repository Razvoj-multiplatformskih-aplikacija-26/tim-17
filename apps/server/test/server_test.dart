@Tags(['db'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:relic/relic.dart' show IOAdapter, RelicServer;
import 'package:server/server.dart';
import 'package:server/src/passwords.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

late Pool<void> database;
late RelicServer server;
late SessionHandlers sessions;
late Uri base;
late String demoPassword;

const testStudents = 6;

Future<String> logIn(String username, {String? password}) async {
  final answer = await http.post(
    base.replace(path: ApiPaths.sessions),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(LoginDto(username: username, password: password ?? demoPassword).toJson()),
  );
  return SessionDto.fromJson(jsonDecode(answer.body) as Map<String, Object?>).token!;
}

Map<String, String> as(String token) => {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

Future<http.Response> apply(String token, String jobId, {String letter = 'Rado bih radio ovaj posao uz fakultet.'}) =>
    http.post(
      base.replace(path: ApiPaths.applications),
      headers: as(token),
      body: jsonEncode(NewApplicationDto(jobId: jobId, letter: letter).toJson()),
    );

Future<StatusChangeOutcomeDto> change(String token, List<String> ids, String to) async {
  final answer = await http.post(
    base.replace(path: ApiPaths.statusChanges),
    headers: as(token),
    body: jsonEncode(StatusChangeDto(ids: ids, to: to).toJson()),
  );
  expect(answer.statusCode, 200, reason: answer.body);
  return StatusChangeOutcomeDto.fromJson(jsonDecode(answer.body) as Map<String, Object?>);
}

Future<String> pending(String studentId, String jobId, {ApplicationStatus status = ApplicationStatus.pending}) async {
  final created = await JobBoardStore(database).insertApplication(
    jobId: JobPostingId(jobId),
    studentId: UserId(studentId),
    appliedAt: DateTime.now(),
    letter: MotivationLetter.stored('Rado bih radio ovaj posao uz fakultet.'),
    status: status,
  );
  return created.id.value;
}

Future<void> migrateWithDbmate(Uri databaseUrl) async {
  final insideCompose = databaseUrl.replace(host: 'db', port: 5432, path: '/jobly_test');
  final result = await Process.run('docker', [
    'compose',
    'run',
    '--rm',
    '-e',
    'DATABASE_URL=$insideCompose',
    'migrate',
  ], workingDirectory: '../..');
  if (result.exitCode != 0) throw StateError('dbmate failed: ${result.stderr}');
}

Map<String, Object?> bodyOf(http.Response response) => jsonDecode(response.body) as Map<String, Object?>;

String codeOf(http.Response response) => bodyOf(response)['code']! as String;

void main() {
  setUpAll(() async {
    final config = ServerConfig.fromEnvironment(serverEnvironment());
    demoPassword = config.demoPassword!;
    final admin = Pool<void>.withUrl(config.databaseUrl);
    await admin.execute('DROP DATABASE IF EXISTS jobly_test WITH (FORCE)');
    await admin.execute('CREATE DATABASE jobly_test');
    await admin.close();
    database = Pool<void>.withUrl(Uri.parse(config.databaseUrl).replace(path: '/jobly_test').toString());
    await migrateWithDbmate(Uri.parse(config.databaseUrl));
    await seedDemoData(database, now: DateTime.now(), demoPassword: demoPassword);
    final hash = await hashPassword(demoPassword);
    for (var n = 1; n <= testStudents; n++) {
      await database.execute(
        Sql.named(
          'INSERT INTO users (id, username, password_hash, role, first_name, last_name) '
          "VALUES (@id, @username, @hash, 'student', 'Test', @username)",
        ),
        parameters: {'id': 'u-test-$n', 'username': 'test$n', 'hash': hash},
      );
    }
    sessions = SessionHandlers(
      accounts: AccountStore(database),
      secret: config.jwtSecret,
      ttl: const Duration(hours: 1),
    );
    final handlers = JobBoardHandlers(
      board: PostgresJobBoard(database),
      clock: const SystemClock(),
      notifications: const LoggingNotificationSender(apiKey: ''),
    );
    server = RelicServer(() => IOAdapter.bind(InternetAddress.loopbackIPv4, port: 0));
    await server.mountAndStart(buildHandler(handlers, sessions, corsOrigins: const []));
    base = Uri.parse('http://localhost:${server.port}');
  });

  tearDownAll(() async {
    await server.close();
    await database.close();
  });

  test('dva referenta istovremeno prihvataju za poslednje mesto: prolazi tačno jedan', () async {
    await pending('u-test-1', 'job-12', status: ApplicationStatus.accepted);
    final second = await pending('u-test-2', 'job-12');
    final third = await pending('u-test-3', 'job-12');
    final first = await logIn('referent1');
    final other = await logIn('referent1');

    final outcomes = await Future.wait([
      change(first, [second], ApplicationStatusDto.accepted),
      change(other, [third], ApplicationStatusDto.accepted),
    ]);

    expect(outcomes.map((o) => o.changed.length), unorderedEquals([1, 0]));
    final slower = outcomes.firstWhere((o) => o.changed.isEmpty);
    expect(slower.errors.single.problem.code, ErrorCodes.noSlotsLeft);
    expect(slower.errors.single.problem.status, 409);
  });

  test('ista prijava poslata dva puta istovremeno: jedna 201, druga already-applied', () async {
    final token = await logIn('test4');

    final answers = await Future.wait([apply(token, 'job-2'), apply(token, 'job-2')]);

    expect(answers.map((a) => a.statusCode), unorderedEquals([201, 409]));
    expect(codeOf(answers.firstWhere((a) => a.statusCode == 409)), ErrorCodes.alreadyApplied);
  });

  test('dva referenta istovremeno menjaju istu prijavu: drugi dobija invalid-transition', () async {
    final id = await pending('u-test-5', 'job-3');
    final first = await logIn('referent1');
    final other = await logIn('referent1');

    final outcomes = await Future.wait([
      change(first, [id], ApplicationStatusDto.rejected),
      change(other, [id], ApplicationStatusDto.rejected),
    ]);

    expect(outcomes.map((o) => o.changed.length), unorderedEquals([1, 0]));
    expect(outcomes.firstWhere((o) => o.changed.isEmpty).errors.single.problem.code, ErrorCodes.invalidTransition);
  });

  test('kratko pismo mimo aplikacije: 422 letter-too-short sa granicom', () async {
    final answer = await apply(await logIn('test6'), 'job-9', letter: 'Kratk');

    expect(answer.statusCode, 422);
    expect(answer.headers['content-type'], startsWith(ProblemDto.mediaType));
    final problem = ProblemDto.fromJson(bodyOf(answer));
    expect(problem.code, ErrorCodes.letterTooShort);
    expect(problem.min, MotivationLetter.minLength);
    expect(problem.value, 5);
  });

  test('student ne sme da menja statuse: 403 not-allowed', () async {
    final answer = await http.post(
      base.replace(path: ApiPaths.statusChanges),
      headers: as(await logIn('student1')),
      body: jsonEncode(const StatusChangeDto(ids: ['app-1'], to: ApplicationStatusDto.accepted).toJson()),
    );

    expect(answer.statusCode, 403);
    expect(codeOf(answer), ErrorCodes.notAllowed);
  });

  test('student ne vidi celu tablu: 403 not-allowed', () async {
    final answer = await http.get(base.replace(path: ApiPaths.applications), headers: as(await logIn('student1')));

    expect(answer.statusCode, 403);
    expect(codeOf(answer), ErrorCodes.notAllowed);
  });

  test('student ne može da povuče tuđu prijavu', () async {
    final answer = await http.post(
      base.replace(path: ApiPaths.withdrawal('app-11')),
      headers: as(await logIn('student1')),
    );

    expect(answer.statusCode, 403);
    expect(codeOf(answer), ErrorCodes.notAllowed);
  });

  test('loša lozinka: 401 invalid-credentials', () async {
    final answer = await http.post(
      base.replace(path: ApiPaths.sessions),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(const LoginDto(username: 'student1', password: 'pogresna').toJson()),
    );

    expect(answer.statusCode, 401);
    expect(codeOf(answer), ErrorCodes.invalidCredentials);
  });

  test('istekao token: 401 session-expired, a bez tokena sign-in-required', () async {
    const student = User(
      id: UserId('u-student'),
      username: 'student1',
      role: UserRole.student,
      firstName: 'Nikola',
      lastName: 'Petrović',
    );
    final expired = sessions.issueToken(student, expiresIn: const Duration(seconds: -10));

    final stale = await http.get(base.replace(path: ApiPaths.jobs), headers: as(expired));
    final missing = await http.get(base.replace(path: ApiPaths.jobs));

    expect(stale.statusCode, 401);
    expect(codeOf(stale), ErrorCodes.sessionExpired);
    expect(missing.statusCode, 401);
    expect(codeOf(missing), ErrorCodes.signInRequired);
  });

  test('početni podaci poštuju pravila i imaju sva stanja', () async {
    final board = PostgresJobBoard(database);
    final seeded = [
      for (final a in await board.allApplications())
        if (a.id.value.startsWith('app-')) a,
    ];
    expect(seeded.length, greaterThanOrEqualTo(10));
    expect({for (final a in seeded) a.status}, ApplicationStatus.values.toSet());
    for (final job in await board.allJobs()) {
      expect(filledSlots(job, seeded), lessThanOrEqualTo(job.requiredWorkers), reason: job.id.value);
    }
    for (final student in {for (final a in seeded) a.studentId}) {
      expect(activeApplicationsOf(student, seeded), lessThanOrEqualTo(maxActiveApplications));
    }
  });
}
