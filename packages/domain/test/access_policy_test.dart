import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const me = User(id: student, role: UserRole.student, firstName: 'Ana', lastName: 'Ilić');
  const someoneElse = User(id: otherStudent, role: UserRole.student, firstName: 'Marko', lastName: 'Jović');
  const referent = User(id: UserId('u-ref'), role: UserRole.staff, firstName: 'Marija', lastName: 'Kostić');
  const employer = User(id: UserId('u-emp'), role: UserRole.employer, firstName: 'Petar', lastName: 'Lukić');

  test('osoblje su referent i poslodavac, a student nije', () {
    expect(UserRole.staff.isStaff, isTrue);
    expect(UserRole.employer.isStaff, isTrue);
    expect(UserRole.student.isStaff, isFalse);
  });

  test('prijavu šalje samo student', () {
    expect(AccessPolicy.canApply(me), isTrue);
    expect(AccessPolicy.canApply(referent), isFalse);
  });

  test('student vidi i povlači samo svoju prijavu', () {
    final mine = application();
    expect(AccessPolicy.canView(me, mine), isTrue);
    expect(AccessPolicy.canView(someoneElse, mine), isFalse);
    expect(AccessPolicy.canWithdraw(me, mine), isTrue);
    expect(AccessPolicy.canWithdraw(someoneElse, mine), isFalse);
  });

  test('osoblje vidi sve prijave, ali ne može da ih povuče umesto studenta', () {
    final mine = application();
    expect(AccessPolicy.canView(referent, mine), isTrue);
    expect(AccessPolicy.canWithdraw(referent, mine), isFalse);
    expect(AccessPolicy.canSetStatus(referent, mine, ApplicationStatus.withdrawn), isFalse);
  });

  test('prihvata, odbija i završava samo osoblje', () {
    final mine = application();
    for (final to in [ApplicationStatus.accepted, ApplicationStatus.rejected, ApplicationStatus.completed]) {
      expect(AccessPolicy.canSetStatus(referent, mine, to), isTrue, reason: to.name);
      expect(AccessPolicy.canSetStatus(employer, mine, to), isTrue, reason: to.name);
      expect(AccessPolicy.canSetStatus(me, mine, to), isFalse, reason: to.name);
    }
  });

  test('mayMove spaja ovlašćenje i dozvoljen prelaz', () {
    expect(AccessPolicy.mayMove(referent, application(), ApplicationStatus.accepted), isTrue);
    expect(AccessPolicy.mayMove(referent, application(), ApplicationStatus.completed), isFalse);
    expect(
      AccessPolicy.mayMove(referent, application(status: ApplicationStatus.accepted), ApplicationStatus.completed),
      isTrue,
    );
    expect(AccessPolicy.mayMove(me, application(), ApplicationStatus.withdrawn), isTrue);
    expect(
      AccessPolicy.mayMove(me, application(status: ApplicationStatus.completed), ApplicationStatus.withdrawn),
      isFalse,
    );
  });
}
