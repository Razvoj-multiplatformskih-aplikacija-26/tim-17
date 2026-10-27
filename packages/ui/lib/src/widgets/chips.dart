import 'package:flutter/material.dart';

import '../jobly_colors.dart';

/// Pilula u Instagram stilu: siva kad nije izabrana, obrnuta (crna ili bela) kad jeste.
class JoblyChip extends StatelessWidget {
  const JoblyChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.count = 0,
    this.showChevron = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;
  final int count;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobly = theme.jobly;
    final active = selected || count > 0;
    final background = active ? jobly.selected : jobly.fill;
    final foreground = active ? jobly.onSelected : theme.colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: active,
      label: count > 0 ? '$label, izabrano $count' : label,
      child: ExcludeSemantics(
        child: Material(
          color: background,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 36,
              padding: EdgeInsets.fromLTRB(icon == null ? 14 : 12, 0, showChevron ? 8 : 14, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 17, color: foreground), const SizedBox(width: 6)],
                  Text(label, style: theme.textTheme.labelMedium?.copyWith(color: foreground)),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(gradient: jobly.gradient, borderRadius: BorderRadius.circular(999)),
                      child: Text('$count', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white)),
                    ),
                  ],
                  if (showChevron) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: foreground),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Oznaka aktivnog filtera koja se uklanja dodirom.
class RemovableTag extends StatelessWidget {
  const RemovableTag({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Semantics(
      button: true,
      label: 'Ukloni filter $label',
      child: ExcludeSemantics(
        child: Material(
          color: color.withValues(alpha: 0.12),
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
                  const SizedBox(width: 4),
                  Icon(Icons.close_rounded, size: 16, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
