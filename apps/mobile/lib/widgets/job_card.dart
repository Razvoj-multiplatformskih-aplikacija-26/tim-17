import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/job_filters.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.onTap});

  final JobPosting job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Semantics(
      button: true,
      label: '${job.title}, ${job.employerName}, ${job.city}, ${job.hourlyRate} dinara po satu',
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
                      Text(
                        '${job.hourlyRate} RSD/h',
                        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(job.employerName, style: muted),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      _Meta(icon: Icons.place_outlined, label: job.city),
                      _Meta(icon: job.shift.icon, label: job.shift.label),
                      _Meta(icon: job.payType.icon, label: job.payType.label),
                      _Meta(icon: Icons.event_outlined, label: 'od ${formatShortDate(job.startsAt)}'),
                    ],
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

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
