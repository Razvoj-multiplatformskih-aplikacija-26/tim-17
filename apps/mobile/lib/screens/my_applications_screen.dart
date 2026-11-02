import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../widgets/application_card.dart';
import '../widgets/top_bar.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MyApplicationsBloc, MyApplicationsState>(
        builder: (context, state) {
          final filter = state is MyApplicationsLoaded ? state.filter : null;
          return CustomScrollView(
            slivers: [
              const JoblyTopBar(),
              const SliverToBoxAdapter(
                child: LargeTitle(title: 'Moje prijave', subtitle: 'Prati gde si se prijavio'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedFrostedBar(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: ApplicationStatus.values.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status = index == 0 ? null : ApplicationStatus.values[index - 1];
                      return JoblyChip(
                        label: status?.groupLabel ?? 'Sve',
                        selected: status == filter,
                        onTap: () => context.read<MyApplicationsBloc>().add(MyApplicationsFilterChanged(status)),
                      );
                    },
                  ),
                ),
              ),
              ..._body(context, state),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _body(BuildContext context, MyApplicationsState state) {
    Widget fill(Widget child) => SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: child,
      ),
    );

    switch (state) {
      case MyApplicationsLoading():
        return [fill(const LoadingView())];
      case MyApplicationsFailure():
        return [
          fill(FailureView(onRetry: () => context.read<MyApplicationsBloc>().add(const MyApplicationsRetried()))),
        ];
      case MyApplicationsEmpty():
        return [
          fill(
            EmptyView(
              icon: Icons.assignment_outlined,
              title: 'Još nemaš prijava',
              message: 'Pronađi oglas koji ti odgovara i prijavi se u par koraka.',
              action: GradientButton(
                onPressed: () => context.go('/'),
                icon: Icons.search_rounded,
                label: 'Pretraži poslove',
              ),
            ),
          ),
        ];
      case MyApplicationsLoaded(:final visible, :final filter):
        if (visible.isEmpty) {
          return [
            fill(
              EmptyView(
                icon: Icons.assignment_outlined,
                title: 'Nema prijava u ovoj grupi',
                message: 'Ovde će se pojaviti prijave sa statusom „${filter?.groupLabel.toLowerCase()}“.',
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.paddingOf(context).bottom),
            sliver: SliverList.separated(
              itemCount: visible.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = visible[index];
                return ApplicationCard(record: record, onTap: () => context.push('/applications/${record.id.value}'));
              },
            ),
          ),
        ];
    }
  }
}
