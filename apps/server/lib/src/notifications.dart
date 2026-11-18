import 'dart:io';

import 'package:domain/domain.dart';

abstract interface class NotificationSender {
  Future<void> applicationAccepted(ApplicationRecord record);
}

final class LoggingNotificationSender implements NotificationSender {
  const LoggingNotificationSender({required this.apiKey, this.out});

  final String apiKey;
  final IOSink? out;

  @override
  Future<void> applicationAccepted(ApplicationRecord record) async {
    final sink = out ?? stdout;
    final signed = apiKey.isEmpty ? 'bez ključa' : 'sa ključem';
    sink.writeln(
      'Obaveštenje ($signed): ${record.candidate.fullName} <${record.candidate.email}> '
      'je primljen/a na oglas "${record.job.title}" (${record.job.employerName}).',
    );
  }
}
