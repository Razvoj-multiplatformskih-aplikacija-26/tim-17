import 'package:design_tokens/design_tokens.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

extension ApplicationStatusLabel on ApplicationStatus {
  String get label => switch (this) {
    ApplicationStatus.pending => 'Na čekanju',
    ApplicationStatus.accepted => 'Prihvaćena',
    ApplicationStatus.rejected => 'Odbijena',
    ApplicationStatus.completed => 'Završena',
  };

  String get groupLabel => switch (this) {
    ApplicationStatus.pending => 'Na čekanju',
    ApplicationStatus.accepted => 'Prihvaćene',
    ApplicationStatus.rejected => 'Odbijene',
    ApplicationStatus.completed => 'Završene',
  };

  IconData get icon => switch (this) {
    ApplicationStatus.pending => Icons.schedule_rounded,
    ApplicationStatus.accepted => Icons.check_circle_outline_rounded,
    ApplicationStatus.rejected => Icons.cancel_outlined,
    ApplicationStatus.completed => Icons.task_alt_rounded,
  };

  Color colorIn(Brightness brightness) {
    final tokens = brightness == Brightness.dark
        ? StatusTokens.dark
        : StatusTokens.light;
    return Color(switch (this) {
      ApplicationStatus.pending => tokens.pending,
      ApplicationStatus.accepted => tokens.accepted,
      ApplicationStatus.rejected => tokens.rejected,
      ApplicationStatus.completed => tokens.completed,
    });
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status, this.size = 8});

  final ApplicationStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status.colorIn(Theme.of(context).brightness),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status.colorIn(theme.brightness);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(status: status, size: 7),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
