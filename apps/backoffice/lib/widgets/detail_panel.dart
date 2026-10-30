import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/board_item.dart';
import 'kbd.dart';

class DetailPanel extends StatelessWidget {
  const DetailPanel({
    super.key,
    required this.item,
    required this.onClose,
    required this.onChange,
    this.fullWidth = false,
  });

  final BoardItem item;
  final VoidCallback onClose;
  final ValueChanged<ApplicationStatus> onChange;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final next = nextStatuses(item.status);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? scheme.surfaceContainerLow : scheme.surface,
        border: fullWidth
            ? null
            : Border(
                left: BorderSide(color: theme.jobly.separator, width: 0.5),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: fullWidth ? 'Nazad (Esc)' : 'Zatvori (Esc)',
                  icon: Icon(
                    fullWidth ? Icons.arrow_back_rounded : Icons.close_rounded,
                  ),
                  onPressed: onClose,
                ),
                const Spacer(),
                Text(
                  'Prijava ${item.id.value}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Row(
                  children: [
                    InitialsAvatar(name: item.candidate.name, size: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.candidate.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(item.candidate.faculty, style: muted),
                          const SizedBox(height: 8),
                          StatusBadge(status: item.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _Group(
                  title: 'Oglas',
                  rows: [
                    _InfoRow(
                      icon: Icons.work_outline_rounded,
                      label: 'Pozicija',
                      value: item.posting.title,
                    ),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      label: 'Grad',
                      value: item.posting.city,
                    ),
                    _InfoRow(
                      icon: Icons.payments_outlined,
                      label: 'Satnica',
                      value: '${item.posting.hourlyRate.round()} RSD/h',
                    ),
                    _InfoRow(
                      icon: Icons.groups_outlined,
                      label: 'Traženo radnika',
                      value: '${item.posting.requiredWorkers}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _Group(
                  title: 'Kandidat',
                  rows: [
                    _InfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: item.candidate.email,
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Telefon',
                      value: item.candidate.phone,
                    ),
                    _InfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'Prijavljen',
                      value: formatDateTime(item.application.appliedAt),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Motivaciono pismo', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: dark
                        ? scheme.surfaceContainerHigh
                        : scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.candidate.letter,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.jobly.separator, width: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: next.isEmpty
                  ? Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text('Prijava je u završnom stanju.', style: muted),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (next.contains(ApplicationStatus.accepted))
                              GradientButton(
                                label: 'Prihvati',
                                icon: Icons.check_rounded,
                                onPressed: () =>
                                    onChange(ApplicationStatus.accepted),
                              ),
                            if (next.contains(ApplicationStatus.completed))
                              GradientButton(
                                label: 'Označi kao završenu',
                                icon: Icons.task_alt_rounded,
                                onPressed: () =>
                                    onChange(ApplicationStatus.completed),
                              ),
                            if (next.contains(ApplicationStatus.rejected))
                              OutlinedButton.icon(
                                onPressed: () =>
                                    onChange(ApplicationStatus.rejected),
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('Odbij'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 14,
                          runSpacing: 6,
                          children: [
                            if (next.contains(ApplicationStatus.accepted))
                              const KeyHint(keyLabel: 'P', label: 'prihvati'),
                            if (next.contains(ApplicationStatus.rejected))
                              const KeyHint(keyLabel: 'O', label: 'odbij'),
                            if (next.contains(ApplicationStatus.completed))
                              const KeyHint(keyLabel: 'Z', label: 'završi'),
                            const KeyHint(keyLabel: 'Esc', label: 'zatvori'),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: dark
                ? theme.colorScheme.surfaceContainerHigh
                : theme.colorScheme.surfaceContainer,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(indent: 44),
                  rows[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
