import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../dependencies.dart';
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
          icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          onPressed: () => context.read<ThemeModeCubit>().toggle(brightness),
        ),
        if (context.read<AppDependencies>().fakeJobBoard != null) const _DemoMenu(),
        const SizedBox(width: 8),
      ],
    );
  }
}

enum _DemoAction { failNext, emptyNext, reload }

class _DemoMenu extends StatelessWidget {
  const _DemoMenu();

  void _run(BuildContext context, _DemoAction action) {
    final board = context.read<AppDependencies>().fakeJobBoard!;
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case _DemoAction.failNext:
        board.failNextRequest();
        messenger.showSnackBar(const SnackBar(content: Text('Sledeći zahtev će pasti.')));
      case _DemoAction.emptyNext:
        board.answerEmptyNext();
        messenger.showSnackBar(const SnackBar(content: Text('Sledeći odgovor će biti prazan.')));
      case _DemoAction.reload:
        context.read<JobsBloc>().add(const JobsRequested());
        context.read<MyApplicationsBloc>().add(const MyApplicationsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_DemoAction>(
      tooltip: 'Demo',
      icon: const Icon(Icons.science_outlined),
      onSelected: (action) => _run(context, action),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _DemoAction.failNext,
          child: ListTile(leading: Icon(Icons.wifi_off_rounded), title: Text('Greška u sledećem zahtevu')),
        ),
        PopupMenuItem(
          value: _DemoAction.emptyNext,
          child: ListTile(leading: Icon(Icons.inbox_outlined), title: Text('Prazan sledeći odgovor')),
        ),
        PopupMenuItem(
          value: _DemoAction.reload,
          child: ListTile(leading: Icon(Icons.refresh_rounded), title: Text('Ponovo učitaj')),
        ),
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
          Semantics(header: true, child: Text(title, style: theme.textTheme.displaySmall)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Frosted(bottom: true, child: SizedBox.expand(child: child));
  }

  @override
  bool shouldRebuild(PinnedFrostedBar oldDelegate) => oldDelegate.child != child || oldDelegate.height != height;
}
