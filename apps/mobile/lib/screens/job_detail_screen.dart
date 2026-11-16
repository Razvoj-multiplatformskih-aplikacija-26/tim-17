import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../dependencies.dart';
import '../models/job_filters.dart';
import '../widgets/info_row.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.id});

  final JobPostingId id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oglas')),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) => switch (state) {
          JobsLoading() => const LoadingView(),
          JobsFailure() => FailureView(onRetry: () => context.read<JobsBloc>().add(const JobsRetried())),
          JobsReady() => switch (state.find(id)) {
            null => const EmptyView(
              icon: Icons.search_off_rounded,
              title: 'Oglas nije pronađen',
              message: 'Moguće je da je oglas uklonjen.',
            ),
            final job => _JobDetail(job: job),
          },
        },
      ),
    );
  }
}

class _JobDetail extends StatelessWidget {
  const _JobDetail({required this.job});

  final JobPosting job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentId = context.read<AppDependencies>().studentId;
    final applications = context.select<MyApplicationsBloc, List<ApplicationRecord>>(
      (bloc) => switch (bloc.state) {
        MyApplicationsLoaded(:final applications) => applications,
        _ => const [],
      },
    );
    final existing = applicationFor(studentId, job.id, [for (final r in applications) r.application]);

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 32 + MediaQuery.paddingOf(context).bottom),
      children: [
        Semantics(header: true, child: Text(job.title, style: theme.textTheme.headlineMedium)),
        const SizedBox(height: 4),
        Text(job.employerName, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        SectionCard(
          children: [
            InfoRow(icon: Icons.place_outlined, label: 'Grad', value: job.city),
            InfoRow(icon: job.category.icon, label: 'Kategorija', value: job.category.label),
            InfoRow(icon: job.shift.icon, label: 'Smena', value: '${job.shift.label}, ${job.hoursPerShift} h'),
            InfoRow(icon: job.payType.icon, label: 'Isplata', value: job.payType.label),
            InfoRow(icon: Icons.payments_outlined, label: 'Satnica', value: '${job.hourlyRate} RSD/h'),
            InfoRow(icon: Icons.event_outlined, label: 'Početak', value: formatDateTime(job.startsAt)),
            InfoRow(icon: Icons.groups_outlined, label: 'Traženo radnika', value: '${job.requiredWorkers}'),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Opis posla',
          children: [Text(job.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4))],
        ),
        const SizedBox(height: 24),
        if (existing != null)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Već si se prijavio: '),
                  StatusBadge(status: existing.status),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/applications/${existing.id.value}'),
                child: const Text('Pogledaj prijavu'),
              ),
            ],
          )
        else if (!job.isOpen)
          Center(child: Text('Oglas je zatvoren.', style: theme.textTheme.titleSmall))
        else
          Center(
            child: GradientButton(
              onPressed: () => context.push('/jobs/${job.id.value}/apply'),
              icon: Icons.send_rounded,
              label: 'Prijavi se',
            ),
          ),
      ],
    );
  }
}
