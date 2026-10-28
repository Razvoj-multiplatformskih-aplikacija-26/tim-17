import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/board_item.dart';

class ApplicationsList extends StatelessWidget {
  const ApplicationsList({
    super.key,
    required this.items,
    required this.cursor,
    required this.checked,
    required this.showFocus,
    required this.controller,
    required this.onTap,
    required this.onToggle,
    required this.empty,
  });

  static const rowExtent = 76.0;

  final List<BoardItem> items;
  final JobApplicationId? cursor;
  final Set<JobApplicationId> checked;
  final bool showFocus;
  final ScrollController controller;
  final ValueChanged<JobApplicationId> onTap;
  final ValueChanged<JobApplicationId> onToggle;
  final Widget empty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return empty;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 96),
      itemExtent: rowExtent,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isCursor = item.id == cursor;
        final isChecked = checked.contains(item.id);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Semantics(
            selected: isCursor,
            label: '${item.candidate.name}, ${item.posting.title}, ${item.status.label}',
            child: Material(
              color: isCursor
                  ? scheme.primary.withValues(alpha: 0.10)
                  : (isChecked ? theme.jobly.fill : Colors.transparent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: isCursor && showFocus ? BorderSide(color: scheme.primary, width: 2) : BorderSide.none,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onTap(item.id),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (_) => onToggle(item.id),
                        semanticLabel: 'Označi ${item.candidate.name}',
                      ),
                      InitialsAvatar(name: item.candidate.name, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.candidate.name,
                              style: theme.textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.posting.title} · ${item.posting.city}',
                              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: item.status),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
