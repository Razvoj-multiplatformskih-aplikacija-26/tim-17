import 'package:flutter/material.dart';

class BulkActionBar extends StatelessWidget {
  const BulkActionBar({
    super.key,
    required this.count,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
    required this.onClear,
  });

  final int count;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = scheme.onInverseSurface;
    Widget action(
      IconData icon,
      String label,
      String key,
      VoidCallback onPressed,
    ) => Tooltip(
      message: '$label ($key)',
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          textStyle: theme.textTheme.labelLarge,
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
    return Material(
      color: scheme.inverseSurface,
      shape: const StadiumBorder(),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            Text(
              '$count izabrano',
              style: theme.textTheme.labelLarge?.copyWith(color: foreground),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: foreground.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 4),
            action(Icons.check_rounded, 'Prihvati', 'P', onAccept),
            action(Icons.close_rounded, 'Odbij', 'O', onReject),
            action(Icons.task_alt_rounded, 'Završi', 'Z', onComplete),
            IconButton(
              tooltip: 'Poništi izbor (Esc)',
              icon: Icon(
                Icons.close_rounded,
                color: foreground.withValues(alpha: 0.7),
              ),
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}
