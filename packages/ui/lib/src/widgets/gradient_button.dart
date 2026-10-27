import 'package:flutter/material.dart';

import '../jobly_colors.dart';

/// Glavno dugme ekrana, obojeno gradijentom brenda.
class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: theme.jobly.gradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: theme.jobly.gradient.colors[1].withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20, color: Colors.white), const SizedBox(width: 8)],
                  Text(label, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
