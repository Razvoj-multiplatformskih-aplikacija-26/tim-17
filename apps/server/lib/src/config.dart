import 'dart:convert';

final class ServerConfig {
  const ServerConfig({
    required this.host,
    required this.port,
    required this.databaseUrl,
    required this.corsOrigins,
    this.sessionTtl = const Duration(hours: 8),
    this.secureCookie = false,
    this.demoPassword,
    required this.jwtSecret,
    this.notificationsApiKey = '',
  });

  factory ServerConfig.fromEnvironment(Map<String, String> environment) => ServerConfig(
    host: environment['HOST'] ?? '127.0.0.1',
    port: int.parse(environment['PORT'] ?? '8080'),
    databaseUrl:
        environment['DATABASE_URL'] ??
        (throw StateError('DATABASE_URL is not set. Copy .env.example to .env in the repository root.')),
    corsOrigins: [
      for (final origin in (environment['CORS_ORIGINS'] ?? 'http://localhost:8081').split(','))
        if (origin.trim().isNotEmpty) origin.trim(),
    ],
    sessionTtl: Duration(minutes: int.parse(environment['SESSION_TTL_MINUTES'] ?? '480')),
    secureCookie: environment['COOKIE_SECURE'] == 'true',
    demoPassword: environment['DEMO_PASSWORD'],
    jwtSecret: _jwtSecret(environment['JWT_SECRET']),
    notificationsApiKey: environment['NOTIFICATIONS_API_KEY'] ?? '',
  );

  final String host;
  final int port;
  final String databaseUrl;
  final List<String> corsOrigins;
  final Duration sessionTtl;
  final bool secureCookie;
  final String? demoPassword;
  final String jwtSecret;
  final String notificationsApiKey;
}

String _jwtSecret(String? secret) => switch (secret) {
  null => throw StateError('JWT_SECRET is not set. Copy .env.example to .env in the repository root.'),
  final secret when utf8.encode(secret).length < 32 => throw StateError('JWT_SECRET must have at least 32 bytes.'),
  final secret => secret,
};
