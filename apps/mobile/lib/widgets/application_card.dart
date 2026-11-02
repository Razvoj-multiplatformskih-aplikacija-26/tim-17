import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.record, required this.onTap});

  final ApplicationRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = record.job;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Semantics(
      button: true,
      label: '${job.title}, ${job.employerName}, ${record.status.label}',
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(job.title, style: theme.textTheme.titleMedium)),
                      const SizedBox(width: 12),
                      StatusBadge(status: record.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${job.employerName} · ${job.city}', style: muted),
                  const SizedBox(height: 8),
                  Text(
                    'Poslato ${formatDateTime(record.application.appliedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
