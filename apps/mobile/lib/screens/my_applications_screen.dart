import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../widgets/top_bar.dart';

// Stanja prijave iz README-ja; kad stigne domenski model, ovaj spisak dolazi odande.
const _statusTabs = ['Sve', 'Na čekanju', 'Prihvaćene', 'Odbijene', 'Završene', 'Povučene'];

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  String _status = _statusTabs.first;

  @override
  Widget build(BuildContext context) {
    final showsAll = _status == _statusTabs.first;
    return Scaffold(
      body: CustomScrollView(
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
                itemCount: _statusTabs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final status = _statusTabs[index];
                  return JoblyChip(
                    label: status,
                    selected: status == _status,
                    onTap: () => setState(() => _status = status),
                  );
                },
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              child: EmptyView(
                icon: Icons.assignment_outlined,
                title: showsAll ? 'Još nemaš prijava' : 'Nema prijava u ovoj grupi',
                message: showsAll
                    ? 'Pronađi oglas koji ti odgovara i prijavi se u par koraka.'
                    : 'Ovde će se pojaviti prijave sa statusom „${_status.toLowerCase()}“.',
                action: showsAll
                    ? GradientButton(
                        onPressed: () => context.go('/'),
                        icon: Icons.search_rounded,
                        label: 'Pretraži poslove',
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
