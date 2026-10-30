import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme_mode.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, this.showLabel = false});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final label = isDark ? 'Svetla tema' : 'Tamna tema';
    final icon = Icon(
      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
    );
    void toggle() => context.read<ThemeModeCubit>().toggle(theme.brightness);
    if (!showLabel)
      return IconButton(tooltip: label, icon: icon, onPressed: toggle);
    return TextButton.icon(
      onPressed: toggle,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: theme.textTheme.titleSmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: icon,
      label: Text(label),
    );
  }
}
