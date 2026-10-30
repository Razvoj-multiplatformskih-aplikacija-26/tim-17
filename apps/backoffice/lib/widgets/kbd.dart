import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class Kbd extends StatelessWidget {
  const Kbd(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.jobly.fill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.jobly.separator),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class KeyHint extends StatelessWidget {
  const KeyHint({super.key, required this.keyLabel, required this.label});

  final String keyLabel;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Kbd(keyLabel),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
