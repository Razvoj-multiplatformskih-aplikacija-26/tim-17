import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

final class BoardItem {
  const BoardItem(this.record);

  final ApplicationRecord record;

  JobApplication get application => record.application;

  JobPosting get posting => record.job;

  Candidate get candidate => record.candidate;

  String get letter => application.letter?.text ?? '';

  JobApplicationId get id => application.id;

  ApplicationStatus get status => application.status;
}

extension ApplicationStatusAction on ApplicationStatus {
  String get doneLabel => switch (this) {
    ApplicationStatus.pending => 'Vraćeno na čekanje',
    ApplicationStatus.accepted => 'Prihvaćeno',
    ApplicationStatus.rejected => 'Odbijeno',
    ApplicationStatus.completed => 'Završeno',
    ApplicationStatus.withdrawn => 'Povučeno',
  };
}

enum BoardView {
  table('Tabela', Icons.table_rows_rounded),
  kanban('Kanban', Icons.view_kanban_rounded);

  const BoardView(this.label, this.icon);

  final String label;
  final IconData icon;
}
