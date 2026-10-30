import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/board_item.dart';

class ApplicationsTable extends StatelessWidget {
  const ApplicationsTable({
    super.key,
    required this.items,
    required this.cursor,
    required this.checked,
    required this.showFocus,
    required this.controller,
    required this.onTap,
    required this.onToggle,
    required this.onToggleAll,
    required this.empty,
  });

  static const rowExtent = 64.0;

  final List<BoardItem> items;
  final JobApplicationId? cursor;
  final Set<JobApplicationId> checked;
  final bool showFocus;
  final ScrollController controller;
  final ValueChanged<JobApplicationId> onTap;
  final ValueChanged<JobApplicationId> onToggle;
  final VoidCallback onToggleAll;

  final Widget empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allChecked = items.isNotEmpty && items.every((item) => checked.contains(item.id));
    final someChecked = items.any((item) => checked.contains(item.id));
    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.6,
    );
    Text header(String label) => Text(label.toUpperCase(), style: headerStyle);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 4, 32, 4),
          child: _cells(
            check: Checkbox(
              tristate: true,
              value: allChecked ? true : (someChecked ? null : false),
              onChanged: items.isEmpty ? null : (_) => onToggleAll(),
              semanticLabel: 'Označi sve',
            ),
            candidate: header('Kandidat'),
            posting: header('Oglas'),
            pay: header('Satnica'),
            date: header('Prijavljen'),
            status: header('Status'),
          ),
        ),
        const Divider(),
        Expanded(
          child: items.isEmpty
              ? empty
              : ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.only(top: 4, bottom: 96),
                  itemExtent: rowExtent,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _TableRow(
                      item: item,
                      isCursor: item.id == cursor,
                      isChecked: checked.contains(item.id),
                      showFocus: showFocus,
                      onTap: () => onTap(item.id),
                      onToggle: () => onToggle(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Widget _cells({
  required Widget check,
  required Widget candidate,
  required Widget posting,
  required Widget pay,
  required Widget date,
  required Widget status,
}) {
  return Row(
    children: [
      SizedBox(
        width: 44,
        child: Align(alignment: Alignment.centerLeft, child: check),
      ),
      Expanded(flex: 5, child: candidate),
      const SizedBox(width: 16),
      Expanded(flex: 5, child: posting),
      const SizedBox(width: 16),
      Expanded(flex: 2, child: pay),
      const SizedBox(width: 16),
      Expanded(flex: 3, child: date),
      SizedBox(
        width: 132,
        child: Align(alignment: Alignment.centerLeft, child: status),
      ),
    ],
  );
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.item,
    required this.isCursor,
    required this.isChecked,
    required this.showFocus,
    required this.onTap,
    required this.onToggle,
  });

  final BoardItem item;
  final bool isCursor;
  final bool isChecked;
  final bool showFocus;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Semantics(
        selected: isCursor,
        label: '${item.candidate.name}, ${item.posting.title}, ${item.status.label}',
        child: Material(
          color: isCursor
              ? scheme.primary.withValues(alpha: 0.10)
              : (isChecked ? theme.jobly.fill : Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isCursor && showFocus ? BorderSide(color: scheme.primary, width: 2) : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _cells(
                check: Checkbox(
                  value: isChecked,
                  onChanged: (_) => onToggle(),
                  semanticLabel: 'Označi ${item.candidate.name}',
                ),
                candidate: Row(
                  children: [
                    InitialsAvatar(name: item.candidate.name, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.candidate.name, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                          Text(item.candidate.faculty, style: muted, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                posting: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.posting.title,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(item.posting.city, style: muted),
                  ],
                ),
                pay: Text('${item.posting.hourlyRate.round()} RSD/h', style: theme.textTheme.bodyMedium),
                date: Text(
                  formatDateTime(item.application.appliedAt),
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                status: StatusBadge(status: item.status),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
