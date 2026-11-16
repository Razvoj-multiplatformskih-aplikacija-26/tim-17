abstract final class ApiPaths {
  static const health = '/health';
  static const jobs = '/api/v1/jobs';
  static const applications = '/api/v1/applications';
  static const myApplications = '/api/v1/me/applications';
  static const statusChanges = '/api/v1/applications/status-changes';
  static const sessions = '/api/v1/sessions';
  static const currentSession = '/api/v1/sessions/current';

  static String job(String id) => '$jobs/$id';

  static String application(String id) => '$applications/$id';

  static String withdrawal(String id) => '${application(id)}/withdrawal';
}

abstract final class ApiCookies {
  static const session = 'jobly_session';
}
