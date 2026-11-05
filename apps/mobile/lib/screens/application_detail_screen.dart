import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../widgets/info_row.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key, required this.id, this.justApplied = false});

  final JobApplicationId id;
  final bool justApplied;

  void _onNotice(BuildContext context, MyApplicationsNotice notice) {
    final messenger = ScaffoldMessenger.of(context);
    context.read<MyApplicationsBloc>().add(const MyApplicationsNoticeAcknowledged());
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (notice) {
          ApplicationWithdrawn() => 'Prijava je povučena.',
          WithdrawRejected(:final error) => error.message,
          WithdrawFailed() => 'Prijava nije povučena. Proveri internet vezu i pokušaj ponovo.',
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void goHome() => context.go('/');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prijava'),
        leading: context.canPop()
            ? null
            : IconButton(tooltip: 'Nazad na poslove', icon: const Icon(Icons.close_rounded), onPressed: goHome),
      ),
      bottomNavigationBar: justApplied
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Center(
                heightFactor: 1,
                child: GradientButton(onPressed: goHome, icon: Icons.home_rounded, label: 'Nazad na poslove'),
              ),
            )
          : null,
      body: BlocConsumer<MyApplicationsBloc, MyApplicationsState>(
        listenWhen: (previous, current) => current is MyApplicationsLoaded && current.notice != null,
        listener: (context, state) => _onNotice(context, (state as MyApplicationsLoaded).notice!),
        builder: (context, state) => switch (state) {
          MyApplicationsLoading() => const LoadingView(),
          MyApplicationsFailure() => FailureView(
            onRetry: () => context.read<MyApplicationsBloc>().add(const MyApplicationsRetried()),
          ),
          MyApplicationsEmpty() => const _NotFound(),
          MyApplicationsLoaded() => switch (state.find(id)) {
            null => const _NotFound(),
            final record => _ApplicationDetail(
              record: record,
              canWithdraw: state.canWithdraw(record),
              withdrawing: state.withdrawingId == record.id,
            ),
          },
        },
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) =>
      const EmptyView(icon: Icons.search_off_rounded, title: 'Prijava nije pronađena');
}

class _ApplicationDetail extends StatelessWidget {
  const _ApplicationDetail({required this.record, required this.canWithdraw, required this.withdrawing});

  final ApplicationRecord record;
  final bool canWithdraw;
  final bool withdrawing;

  Future<void> _confirmWithdraw(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Povući prijavu?'),
        content: Text(
          'Prijava za oglas „${record.job.title}“ biće povučena. Ova radnja ne može da se poništi, '
          'a mesto može dobiti drugi kandidat.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Odustani')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Povuci prijavu'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<MyApplicationsBloc>().add(WithdrawRequested(record.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = record.job;
    final letter = record.application.letter;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 32 + MediaQuery.paddingOf(context).bottom),
      children: [
        Semantics(header: true, child: Text(job.title, style: theme.textTheme.headlineMedium)),
        const SizedBox(height: 4),
        Text(
          '${job.employerName} · ${job.city}',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(status: record.status),
        ),
        const SizedBox(height: 16),
        SectionCard(
          children: [
            InfoRow(icon: Icons.send_outlined, label: 'Poslato', value: formatDateTime(record.application.appliedAt)),
            InfoRow(icon: Icons.event_outlined, label: 'Početak rada', value: formatDateTime(job.startsAt)),
            InfoRow(icon: Icons.payments_outlined, label: 'Satnica', value: '${job.hourlyRate} RSD/h'),
          ],
        ),
        if (letter != null) ...[
          const SizedBox(height: 12),
          SectionCard(
            title: 'Motivaciono pismo',
            children: [Text(letter.text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4))],
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => context.push('/jobs/${job.id.value}'),
          icon: const Icon(Icons.work_outline_rounded),
          label: const Text('Pogledaj oglas'),
        ),
        if (canWithdraw) ...[
          const SizedBox(height: 12),
          if (withdrawing)
            const Center(
              child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
            )
          else
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
              onPressed: () => _confirmWithdraw(context),
              icon: const Icon(Icons.undo_rounded),
              label: const Text('Povuci prijavu'),
            ),
        ],
      ],
    );
  }
}
