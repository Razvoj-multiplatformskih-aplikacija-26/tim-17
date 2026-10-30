import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'theme_toggle.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.compact, required this.pendingCount});

  final bool compact;
  final int pendingCount;

  static const _staffName = 'Marija Kostić';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Container(
      width: compact ? 76 : 248,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: compact ? 12 : 16),
      decoration: BoxDecoration(
        color: dark ? theme.colorScheme.surfaceContainerLowest : theme.colorScheme.surfaceContainerLow,
        border: Border(right: BorderSide(color: theme.jobly.separator, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: [
          if (compact)
            const GradientMask(
              child: Text('j', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  const JoblyWordmark(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: theme.jobly.fill, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'backoffice',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          _NavItem(icon: Icons.inbox_rounded, label: 'Prijave', badge: pendingCount, compact: compact, selected: true),
          const Spacer(),
          ThemeToggleButton(showLabel: !compact),
          const SizedBox(height: 12),
          Divider(color: theme.jobly.separator),
          const SizedBox(height: 12),
          if (compact)
            const Tooltip(
              message: '$_staffName · referent',
              child: InitialsAvatar(name: _staffName, size: 36),
            )
          else
            Row(
              children: [
                const InitialsAvatar(name: _staffName, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_staffName, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                      Text(
                        'Referent zadruge',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.badge,
    required this.compact,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final int badge;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobly = theme.jobly;
    final counter = Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(gradient: jobly.gradient, borderRadius: BorderRadius.circular(999)),
      child: Text('$badge', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white)),
    );
    return Semantics(
      selected: selected,
      label: '$label, $badge na čekanju',
      child: ExcludeSemantics(
        child: Tooltip(
          message: compact ? label : '',
          child: Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
            decoration: BoxDecoration(color: selected ? jobly.fill : null, borderRadius: BorderRadius.circular(10)),
            child: compact
                ? Badge(
                    isLabelVisible: badge > 0,
                    backgroundColor: theme.colorScheme.secondary,
                    smallSize: 8,
                    child: Center(child: Icon(icon, size: 22)),
                  )
                : Row(
                    children: [
                      Icon(icon, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
                      if (badge > 0) counter,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
