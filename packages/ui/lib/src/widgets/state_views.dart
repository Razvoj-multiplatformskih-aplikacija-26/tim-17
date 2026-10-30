import 'package:flutter/material.dart';

import '../jobly_colors.dart';
import 'gradient_button.dart';
import 'jobly_wordmark.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Učitavanje',
      liveRegion: true,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, this.message, this.icon = Icons.work_outline_rounded, this.action});

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateView(icon: icon, title: title, message: message, action: action);
  }
}

class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.onRetry, this.title = 'Podaci trenutno nisu dostupni.'});

  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: Icons.wifi_off_rounded,
      title: title,
      message: 'Proveri internet vezu i pokušaj ponovo.',
      liveRegion: true,
      action: GradientButton(onPressed: onRetry, icon: Icons.refresh_rounded, label: 'Pokušaj ponovo'),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.icon, required this.title, this.message, this.action, this.liveRegion = false});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.jobly.gradient.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 24, 40, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [for (final color in colors) color.withValues(alpha: 0.14)],
                  ),
                ),
                child: GradientMask(child: Icon(icon, size: 44)),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              liveRegion: liveRegion,
              child: Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.35),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
