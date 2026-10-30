import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/board_item.dart';
import 'kbd.dart';
import 'theme_toggle.dart';

class BoardHeader extends StatelessWidget {
  const BoardHeader({
    super.key,
    required this.total,
    required this.postings,
    required this.search,
    required this.searchFocus,
    required this.onQuery,
    required this.view,
    required this.onView,
    required this.onShortcuts,
    required this.compact,
  });

  final int total;
  final int postings;
  final TextEditingController search;
  final FocusNode searchFocus;
  final ValueChanged<String> onQuery;
  final BoardView view;
  final ValueChanged<BoardView> onView;
  final VoidCallback onShortcuts;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Prijave kandidata',
            style: compact ? theme.textTheme.headlineMedium : theme.textTheme.displaySmall,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$total ${pluralize(total, one: 'prijava', few: 'prijave', many: 'prijava')} · '
          '$postings ${pluralize(postings, one: 'oglas', few: 'oglasa', many: 'oglasa')}',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
    final searchField = _SearchField(controller: search, focusNode: searchFocus, onChanged: onQuery);
    final shortcutsButton = IconButton(
      tooltip: 'Prečice na tastaturi (?)',
      icon: const Icon(Icons.keyboard_alt_outlined),
      onPressed: onShortcuts,
    );
    if (compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(children: [JoblyWordmark(size: 24), Spacer(), ThemeToggleButton()]),
            const SizedBox(height: 12),
            title,
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 8),
                  ViewSwitcher(value: view, onChanged: onView, showLabels: false),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: title),
          const SizedBox(width: 16),
          SizedBox(width: 300, child: searchField),
          const SizedBox(width: 12),
          ViewSwitcher(value: view, onChanged: onView),
          const SizedBox(width: 4),
          shortcutsButton,
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.focusNode, required this.onChanged});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Pretraži kandidate i oglase',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
        prefixIcon: Icon(Icons.search_rounded, color: muted),
        suffixIcon: controller.text.isEmpty
            ? const Padding(padding: EdgeInsets.all(10), child: Kbd('/'))
            : IconButton(
                tooltip: 'Obriši pretragu',
                icon: Icon(Icons.cancel_rounded, size: 20, color: muted),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 40),
      ),
    );
  }
}

class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({super.key, required this.value, required this.onChanged, this.showLabels = true});

  final BoardView value;
  final ValueChanged<BoardView> onChanged;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: theme.jobly.fill, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, view) in BoardView.values.indexed)
            Tooltip(
              message: '${view.label} (${index + 1})',
              child: Semantics(
                button: true,
                selected: view == value,
                label: view.label,
                child: GestureDetector(
                  onTap: () => onChanged(view),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: showLabels ? 14 : 10, vertical: 7),
                    decoration: view == value
                        ? BoxDecoration(
                            color: dark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: dark ? 0.3 : 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          )
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(view.icon, size: 18),
                        if (showLabels) ...[
                          const SizedBox(width: 6),
                          Text(view.label, style: theme.textTheme.labelMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BoardToolbar extends StatelessWidget {
  const BoardToolbar({
    super.key,
    required this.statusFilter,
    required this.counts,
    required this.onStatus,
    required this.postings,
    required this.postingFilter,
    required this.onPosting,
    required this.compact,
  });

  final ApplicationStatus? statusFilter;
  final Map<ApplicationStatus, int> counts;
  final ValueChanged<ApplicationStatus?> onStatus;
  final List<JobPosting> postings;
  final JobPostingId? postingFilter;
  final ValueChanged<JobPostingId?> onPosting;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold(0, (sum, count) => sum + count);
    final selectedPosting = postings.where((posting) => posting.id == postingFilter).firstOrNull;
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32, vertical: 10),
        children: [
          JoblyChip(label: 'Sve $total', selected: statusFilter == null, onTap: () => onStatus(null)),
          for (final status in ApplicationStatus.values) ...[
            const SizedBox(width: 8),
            JoblyChip(
              label: '${status.groupLabel} ${counts[status] ?? 0}',
              icon: status.icon,
              selected: statusFilter == status,
              onTap: () => onStatus(statusFilter == status ? null : status),
            ),
          ],
          const SizedBox(width: 16),
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                leadingIcon: _Check(visible: postingFilter == null),
                onPressed: () => onPosting(null),
                child: const Text('Svi oglasi'),
              ),
              for (final posting in postings)
                MenuItemButton(
                  leadingIcon: _Check(visible: posting.id == postingFilter),
                  onPressed: () => onPosting(posting.id),
                  child: Text('${posting.title} · ${posting.city}'),
                ),
            ],
            builder: (context, controller, child) => JoblyChip(
              label: selectedPosting?.title ?? 'Svi oglasi',
              icon: Icons.work_outline_rounded,
              selected: selectedPosting != null,
              showChevron: true,
              onTap: () => controller.isOpen ? controller.close() : controller.open(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    child: visible ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
  );
}
