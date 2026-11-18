import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

import 'job_board_store.dart';
import 'passwords.dart';

typedef _Person = ({String id, String? username, UserRole role, String name, String faculty, String phone});

const _accounts = <_Person>[
  (
    id: 'u-student',
    username: 'student1',
    role: UserRole.student,
    name: 'Nikola Petrović',
    faculty: 'Računarski fakultet',
    phone: '+381 64 123 4567',
  ),
  (
    id: 'u-ana',
    username: 'student2',
    role: UserRole.student,
    name: 'Ana Jovanović',
    faculty: 'Ekonomski fakultet',
    phone: '+381 63 222 3344',
  ),
  (
    id: 'u-referent',
    username: 'referent1',
    role: UserRole.staff,
    name: 'Nikola Vasiljević',
    faculty: '',
    phone: '+381 11 300 4000',
  ),
  (
    id: 'u-poslodavac',
    username: 'poslodavac1',
    role: UserRole.employer,
    name: 'Milan Stanić',
    faculty: '',
    phone: '+381 11 300 5000',
  ),
];

const _students = [
  ('u-marko', 'Marko Ilić', 'Fakultet organizacionih nauka'),
  ('u-cand-3', 'Jelena Stojanović', 'Filološki fakultet'),
  ('u-cand-4', 'Stefan Nikolić', 'Elektrotehnički fakultet'),
  ('u-cand-5', 'Milica Đorđević', 'Pravni fakultet'),
  ('u-cand-6', 'Luka Pavlović', 'Računarski fakultet'),
  ('u-cand-7', 'Teodora Marković', 'Fakultet političkih nauka'),
  ('u-cand-8', 'Nemanja Kostić', 'Mašinski fakultet'),
  ('u-cand-9', 'Sara Popović', 'Filozofski fakultet'),
  ('u-cand-10', 'Vuk Lazić', 'Fakultet sporta'),
  ('u-cand-11', 'Katarina Simić', 'Medicinski fakultet'),
  ('u-cand-12', 'Aleksa Živković', 'Građevinski fakultet'),
  ('u-cand-13', 'Ivana Todorović', 'Učiteljski fakultet'),
  ('u-cand-14', 'Petar Ristić', 'Saobraćajni fakultet'),
  ('u-cand-15', 'Nina Milošević', 'Fakultet likovnih umetnosti'),
  ('u-cand-16', 'Đorđe Stanković', 'Ekonomski fakultet'),
  ('u-cand-17', 'Maja Vasić', 'Tehnološki fakultet'),
  ('u-cand-18', 'Filip Mitrović', 'Računarski fakultet'),
  ('u-cand-19', 'Tamara Ćirić', 'Fakultet za turizam'),
  ('u-cand-20', 'Uroš Jakovljević', 'Poljoprivredni fakultet'),
  ('u-cand-21', 'Lena Bogdanović', 'Farmaceutski fakultet'),
  ('u-cand-22', 'Ognjen Radović', 'Fakultet tehničkih nauka'),
];

const _jobs = [
  (
    'job-1',
    'Logistika Plus',
    'Radnik u magacinu',
    'Prijem, sortiranje i pakovanje robe. Rad u timu, obezbeđena zaštitna oprema.',
    'Beograd',
    JobCategory.warehouse,
    WorkShift.morning,
    PayType.hourly,
    450,
    5,
    4,
    2,
    JobStatus.open,
  ),
  (
    'job-2',
    'Promo Tim',
    'Promoter u tržnom centru',
    'Predstavljanje novog napitka kupcima i podela uzoraka tokom vikenda.',
    'Novi Sad',
    JobCategory.promotion,
    WorkShift.weekend,
    PayType.daily,
    520,
    4,
    6,
    1,
    JobStatus.open,
  ),
  (
    'job-3',
    'Kafe Centar',
    'Konobar / konobarica',
    'Posluživanje gostiju u kafeu u centru grada. Iskustvo je prednost, ali nije uslov.',
    'Niš',
    JobCategory.hospitality,
    WorkShift.afternoon,
    PayType.hourly,
    420,
    3,
    3,
    5,
    JobStatus.open,
  ),
  (
    'job-4',
    'Market Maxi',
    'Kasir u supermarketu',
    'Rad na kasi, slaganje robe na police i pomoć kupcima.',
    'Beograd',
    JobCategory.retail,
    WorkShift.afternoon,
    PayType.hourly,
    400,
    6,
    2,
    8,
    JobStatus.open,
  ),
  (
    'job-5',
    'Brza Dostava',
    'Dostavljač na biciklu',
    'Dostava hrane u užem centru grada. Bicikl obezbeđuje poslodavac.',
    'Kragujevac',
    JobCategory.delivery,
    WorkShift.flexible,
    PayType.perTask,
    380,
    8,
    1,
    10,
    JobStatus.open,
  ),
  (
    'job-6',
    'Event Pro',
    'Hostesa na sajmu',
    'Doček posetilaca, podela materijala i usmeravanje na štandove.',
    'Beograd',
    JobCategory.events,
    WorkShift.morning,
    PayType.daily,
    600,
    10,
    9,
    4,
    JobStatus.open,
  ),
  (
    'job-7',
    'Biro Servis',
    'Unos podataka',
    'Unos i provera podataka u internoj aplikaciji, rad u kancelariji.',
    'Subotica',
    JobCategory.office,
    WorkShift.morning,
    PayType.hourly,
    480,
    2,
    5,
    6,
    JobStatus.open,
  ),
  (
    'job-8',
    'Pekara Zlatno Zrno',
    'Pomoćni radnik u pekari',
    'Pakovanje peciva i priprema porudžbina u noćnoj smeni.',
    'Novi Sad',
    JobCategory.hospitality,
    WorkShift.night,
    PayType.hourly,
    550,
    2,
    2,
    3,
    JobStatus.open,
  ),
  (
    'job-9',
    'Kod Studio',
    'Tester mobilnih aplikacija',
    'Ručno testiranje aplikacija po scenarijima i prijava grešaka.',
    'Beograd',
    JobCategory.it,
    WorkShift.flexible,
    PayType.hourly,
    750,
    3,
    7,
    2,
    JobStatus.open,
  ),
  (
    'job-10',
    'Logistika Plus',
    'Popis robe',
    'Godišnji popis robe u magacinu.',
    'Beograd',
    JobCategory.warehouse,
    WorkShift.weekend,
    PayType.daily,
    500,
    6,
    -20,
    35,
    JobStatus.closed,
  ),
  (
    'job-11',
    'Event Pro',
    'Redar na koncertu',
    'Kontrola ulaznica i usmeravanje publike.',
    'Niš',
    JobCategory.events,
    WorkShift.night,
    PayType.daily,
    650,
    12,
    -12,
    25,
    JobStatus.closed,
  ),
  (
    'job-12',
    'Knjižara Delfi',
    'Prodavac u knjižari',
    'Rad sa kupcima, preporuke knjiga i rad na kasi.',
    'Kragujevac',
    JobCategory.retail,
    WorkShift.afternoon,
    PayType.hourly,
    430,
    2,
    8,
    1,
    JobStatus.open,
  ),
];

const _letters = [
  'Odgovoran sam, tačan i rado učim nove stvari. Slobodan sam u traženim terminima.',
  'Imam iskustva sa sličnim poslom iz prošle sezone i volim rad u timu.',
  'Studiram vanredno, pa mi ovaj raspored odgovara. Komunikativna sam i snalažljiva.',
  'Tražim posao uz fakultet i mogu da počnem odmah. Imam vozačku dozvolu B kategorije.',
  'Radio sam kao promoter i konobar, navikao sam na rad sa ljudima i gužvu.',
  'Pažljiva sam i precizna, a rad za računarom mi je svakodnevica.',
];

const _pending = ApplicationStatus.pending;
const _accepted = ApplicationStatus.accepted;
const _rejected = ApplicationStatus.rejected;
const _completed = ApplicationStatus.completed;
const _withdrawn = ApplicationStatus.withdrawn;

const _mine = [
  ('job-1', _pending, 1),
  ('job-2', _pending, 1),
  ('job-3', _pending, 3),
  ('job-4', _accepted, 7),
  ('job-5', _rejected, 9),
  ('job-6', _withdrawn, 4),
  ('job-7', _rejected, 5),
  ('job-9', _withdrawn, 2),
  ('job-10', _completed, 30),
  ('job-11', _completed, 22),
];

const _plan = [
  ('u-ana', 1, _pending, 1),
  ('u-marko', 1, _pending, 2),
  ('u-cand-3', 2, _pending, 1),
  ('u-cand-4', 3, _pending, 3),
  ('u-cand-5', 4, _pending, 2),
  ('u-cand-6', 5, _pending, 4),
  ('u-cand-7', 6, _pending, 1),
  ('u-cand-8', 6, _pending, 2),
  ('u-cand-9', 7, _pending, 3),
  ('u-cand-10', 9, _pending, 1),
  ('u-cand-11', 2, _pending, 2),
  ('u-cand-12', 3, _pending, 5),
  ('u-cand-13', 4, _pending, 1),
  ('u-cand-14', 9, _pending, 2),
  ('u-cand-15', 1, _accepted, 5),
  ('u-cand-16', 2, _accepted, 4),
  ('u-cand-17', 4, _accepted, 8),
  ('u-cand-18', 6, _accepted, 3),
  ('u-cand-19', 7, _accepted, 6),
  ('u-cand-20', 8, _accepted, 2),
  ('u-cand-21', 8, _accepted, 2),
  ('u-cand-22', 5, _accepted, 9),
  ('u-ana', 3, _rejected, 7),
  ('u-marko', 7, _rejected, 6),
  ('u-cand-3', 9, _rejected, 2),
  ('u-cand-4', 6, _rejected, 3),
  ('u-cand-5', 8, _rejected, 3),
  ('u-cand-6', 10, _completed, 30),
  ('u-cand-7', 10, _completed, 31),
  ('u-cand-8', 10, _completed, 29),
  ('u-cand-9', 10, _completed, 33),
  ('u-cand-10', 1, _withdrawn, 4),
  ('u-cand-11', 4, _withdrawn, 6),
  ('u-cand-12', 5, _withdrawn, 8),
  ('u-cand-13', 8, _pending, 1),
];

int _hoursFor(WorkShift shift) => switch (shift) {
  WorkShift.morning => 8,
  WorkShift.afternoon => 6,
  WorkShift.night => 9,
  WorkShift.weekend => 10,
  WorkShift.flexible => 4,
};

String _ascii(String text) => text
    .toLowerCase()
    .replaceAll('č', 'c')
    .replaceAll('ć', 'c')
    .replaceAll('š', 's')
    .replaceAll('ž', 'z')
    .replaceAll('đ', 'dj');

Future<void> seedDemoData(Pool<void> database, {required DateTime now, required String? demoPassword}) async {
  if (!await JobBoardStore(database).isEmpty()) return;
  if (demoPassword == null) throw StateError('DEMO_PASSWORD is not set. Copy .env.example to .env.');
  final hashes = [for (final _ in _accounts) await hashPassword(demoPassword)];
  await database.runTx((session) => _seed(session, now: now.toUtc(), hashes: hashes));
}

Future<void> _seed(Session database, {required DateTime now, required List<String> hashes}) async {
  final store = JobBoardStore(database);
  final people = <_Person>[
    ..._accounts,
    for (final (index, (id, name, faculty)) in _students.indexed)
      (
        id: id,
        username: null,
        role: UserRole.student,
        name: name,
        faculty: faculty,
        phone: '+381 6${index % 7} ${(100 + index * 37) % 900 + 100} ${(2000 + index * 413) % 8000 + 1000}',
      ),
  ];
  for (final (index, person) in people.indexed) {
    final [first, ...rest] = person.name.split(' ');
    await database.execute(
      Sql.named('''
        INSERT INTO users (id, username, password_hash, role, first_name, last_name, faculty, email, phone)
        VALUES (@id, @username, @hash, @role, @first, @last, @faculty, @email, @phone)
      '''),
      parameters: {
        'id': person.id,
        'username': person.username ?? person.id.substring(2),
        'hash': TypedValue(Type.text, index < hashes.length ? hashes[index] : null),
        'role': person.role.name,
        'first': first,
        'last': rest.join(' '),
        'faculty': person.faculty,
        'email':
            '${_ascii(person.name).replaceAll(' ', '.')}@${person.role == UserRole.student ? 'student.rs' : 'jobly.rs'}',
        'phone': person.phone,
      },
    );
  }

  for (final (id, employer, title, description, city, category, shift, payType, rate, workers, starts, posted, status)
      in _jobs) {
    await store.insertJob(
      JobPosting(
        id: JobPostingId(id),
        employerId: EmployerId('emp-${_ascii(employer).replaceAll(' ', '-')}'),
        employerName: employer,
        title: title,
        description: description,
        city: city,
        category: category,
        shift: shift,
        payType: payType,
        hourlyRate: rate,
        requiredWorkers: workers,
        startsAt: now.add(Duration(days: starts)),
        postedAt: now.subtract(Duration(days: posted)),
        hoursPerShift: _hoursFor(shift),
        status: status,
      ),
    );
  }

  var next = 1;
  Future<void> seed(String studentId, String jobId, ApplicationStatus status, DateTime appliedAt) async {
    final index = next++;
    await store.insertApplication(
      id: JobApplicationId('app-$index'),
      jobId: JobPostingId(jobId),
      studentId: UserId(studentId),
      status: status,
      appliedAt: appliedAt,
      letter: MotivationLetter.stored(_letters[index % _letters.length]),
    );
  }

  for (final (jobId, status, daysAgo) in _mine) {
    await seed('u-student', jobId, status, now.subtract(Duration(days: daysAgo)));
  }
  for (final (index, (studentId, job, status, daysAgo)) in _plan.indexed) {
    await seed(studentId, 'job-$job', status, now.subtract(Duration(days: daysAgo, hours: index * 3 % 11)));
  }
}
