import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/board_item.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({
    super.key,
    required this.items,
    required this.cursor,
    required this.checked,
    required this.showFocus,
    required this.onTap,
    required this.onToggle,
    required this.canMove,
    required this.onMove,
    required this.keyFor,
    required this.horizontalPadding,
  });

  final List<BoardItem> items;
  final JobApplicationId? cursor;
  final Set<JobApplicationId> checked;
  final bool showFocus;
  final ValueChanged<JobApplicationId> onTap;
  final ValueChanged<JobApplicationId> onToggle;
  final bool Function(JobApplicationId id, ApplicationStatus to) canMove;
  final void Function(JobApplicationId id, ApplicationStatus to) onMove;
  final GlobalKey Function(JobApplicationId id) keyFor;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        const columns = 4;
        final available =
            constraints.maxWidth - horizontalPadding * 2 - gap * (columns - 1);
        final columnWidth = math.max(260.0, available / columns);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            4,
            horizontalPadding,
            24,
          ),
          child: SizedBox(
            height: math.max(0, constraints.maxHeight - 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, status)
                    in ApplicationStatus.values.indexed) ...[
                  if (index > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: columnWidth,
                    child: _Column(
                      status: status,
                      items: [
                        for (final item in items)
                          if (item.status == status) item,
                      ],
                      board: this,
                      width: columnWidth,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.status,
    required this.items,
    required this.board,
    required this.width,
  });

  final ApplicationStatus status;
  final List<BoardItem> items;
  final KanbanBoard board;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurfaceVariant;
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          board.canMove(JobApplicationId(details.data), status),
      onAcceptWithDetails: (details) =>
          board.onMove(JobApplicationId(details.data), status),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: dark
                ? theme.colorScheme.surfaceContainerLow
                : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hovering ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    StatusDot(status: status),
                    const SizedBox(width: 8),
                    Text(status.groupLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? theme.colorScheme.surfaceContainerHigh
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${items.length}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status.icon,
                              size: 28,
                              color: muted.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nema prijava',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Column(
                          children: [
                            for (final item in items)
                              Padding(
                                key: board.keyFor(item.id),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _DraggableCard(
                                  item: item,
                                  board: board,
                                  width: width - 20,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableCard extends StatelessWidget {
  const _DraggableCard({
    required this.item,
    required this.board,
    required this.width,
  });

  final BoardItem item;
  final KanbanBoard board;
  final double width;

  @override
  Widget build(BuildContext context) {
    _KanbanCard card({bool lifted = false}) => _KanbanCard(
      item: item,
      isCursor: item.id == board.cursor,
      isChecked: board.checked.contains(item.id),
      showFocus: board.showFocus,
      lifted: lifted,
      onTap: () => board.onTap(item.id),
      onToggle: () => board.onToggle(item.id),
    );
    return Draggable<String>(
      data: item.id.value,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: width,
          child: Transform.rotate(angle: 0.03, child: card(lifted: true)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card()),
      child: card(),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({
    required this.item,
    required this.isCursor,
    required this.isChecked,
    required this.showFocus,
    required this.lifted,
    required this.onTap,
    required this.onToggle,
  });

  final BoardItem item;
  final bool isCursor;
  final bool isChecked;
  final bool showFocus;
  final bool lifted;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Semantics(
      selected: isCursor,
      label:
          '${item.candidate.name}, ${item.posting.title}, ${item.status.label}',
      child: Material(
        color: dark ? scheme.surfaceContainerHigh : scheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCursor ? scheme.primary : theme.jobly.separator,
                width: isCursor ? (showFocus ? 2 : 1.5) : 0.5,
              ),
              boxShadow: [
                if (lifted)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  )
                else if (!dark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InitialsAvatar(name: item.candidate.name, size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.candidate.name,
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.candidate.faculty,
                            style: muted,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox.square(
                      dimension: 28,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (_) => onToggle(),
                        visualDensity: VisualDensity.compact,
                        semanticLabel: 'Označi ${item.candidate.name}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.posting.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item.posting.city, style: muted)),
                    Text(
                      '${item.posting.hourlyRate.round()} RSD/h',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(formatDateTime(item.application.appliedAt), style: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
