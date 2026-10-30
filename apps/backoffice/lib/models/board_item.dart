import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

final class Candidate {
  const Candidate({
    required this.name,
    required this.faculty,
    required this.email,
    required this.phone,
    required this.letter,
  });

  final String name;
  final String faculty;
  final String email;
  final String phone;
  final String letter;
}

final class BoardItem {
  const BoardItem({
    required this.application,
    required this.posting,
    required this.candidate,
  });

  final JobApplication application;
  final JobPosting posting;
  final Candidate candidate;

  JobApplicationId get id => application.id;

  ApplicationStatus get status => application.status;

  BoardItem withStatus(ApplicationStatus status) => BoardItem(
    application: JobApplication(
      id: application.id,
      jobId: application.jobId,
      studentId: application.studentId,
      status: status,
      appliedAt: application.appliedAt,
    ),
    posting: posting,
    candidate: candidate,
  );
}

Set<ApplicationStatus> nextStatuses(ApplicationStatus from) => switch (from) {
  ApplicationStatus.pending => {
    ApplicationStatus.accepted,
    ApplicationStatus.rejected,
  },
  ApplicationStatus.accepted => {
    ApplicationStatus.completed,
    ApplicationStatus.rejected,
  },
  ApplicationStatus.rejected || ApplicationStatus.completed => const {},
};

extension ApplicationStatusAction on ApplicationStatus {
  String get doneLabel => switch (this) {
    ApplicationStatus.pending => 'Vraćeno na čekanje',
    ApplicationStatus.accepted => 'Prihvaćeno',
    ApplicationStatus.rejected => 'Odbijeno',
    ApplicationStatus.completed => 'Završeno',
  };
}

enum BoardView {
  table('Tabela', Icons.table_rows_rounded),
  kanban('Kanban', Icons.view_kanban_rounded);

  const BoardView(this.label, this.icon);

  final String label;
  final IconData icon;
}
