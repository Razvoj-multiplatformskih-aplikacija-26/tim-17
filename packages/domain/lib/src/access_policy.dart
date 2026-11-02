import 'models/application_status.dart';
import 'models/job_application.dart';
import 'models/user.dart';

abstract final class AccessPolicy {
  static bool canApply(User user) => user.role == UserRole.student;

  static bool canView(User user, JobApplication application) => user.role.isStaff || application.studentId == user.id;

  static bool canWithdraw(User user, JobApplication application) =>
      user.role == UserRole.student && application.studentId == user.id;

  static bool canReview(User user) => user.role.isStaff;

  static bool canSetStatus(User user, JobApplication application, ApplicationStatus to) => switch (to) {
    ApplicationStatus.withdrawn => canWithdraw(user, application),
    ApplicationStatus.accepted || ApplicationStatus.rejected || ApplicationStatus.completed => canReview(user),
    ApplicationStatus.pending => false,
  };

  static bool mayMove(User user, JobApplication application, ApplicationStatus to) =>
      canSetStatus(user, application, to) && canTransition(application.status, to);
}
