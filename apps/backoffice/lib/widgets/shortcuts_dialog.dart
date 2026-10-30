import 'package:flutter/material.dart';

import '../shortcuts.dart';
import 'kbd.dart';

class ShortcutsDialog extends StatelessWidget {
  const ShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Prečice na tastaturi'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final shortcut in shortcutDescriptions())
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Wrap(
                        spacing: 4,
                        children: [for (final key in shortcut.keys) Kbd(key)],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        shortcut.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Zatvori'),
        ),
      ],
    );
  }
}
