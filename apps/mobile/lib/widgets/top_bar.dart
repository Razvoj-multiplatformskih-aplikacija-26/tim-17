import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../theme_mode.dart';

class JoblyTopBar extends StatelessWidget {
  const JoblyTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      titleSpacing: 20,
      title: const JoblyWordmark(),
      actions: [
        IconButton(
          tooltip: isDark ? 'Svetla tema' : 'Tamna tema',
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          onPressed: () => context.read<ThemeModeCubit>().toggle(brightness),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class LargeTitle extends StatelessWidget {
  const LargeTitle({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class PinnedFrostedBar extends SliverPersistentHeaderDelegate {
  const PinnedFrostedBar({required this.child, this.height = 60});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Frosted(bottom: true, child: SizedBox.expand(child: child));
  }

  @override
  bool shouldRebuild(PinnedFrostedBar oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}
