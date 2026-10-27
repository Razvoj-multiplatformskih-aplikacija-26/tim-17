import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/job_filters.dart';
import '../widgets/category_stories.dart';
import '../widgets/filter_sheets.dart';
import '../widgets/job_search_field.dart';
import '../widgets/top_bar.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _search = TextEditingController();
  JobFilters _filters = const JobFilters();

  // Oglasi stižu sa repozitorijumom; do tada je lista prazna.
  static const _jobCount = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _apply(JobFilters filters) => setState(() => _filters = filters);

  Set<T> _toggled<T>(Set<T> set, T value) => set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  Future<void> _pickCities() async {
    final cities = await showChoiceSheet<String>(
      context,
      title: 'Grad',
      options: serbianCities,
      selected: _filters.cities,
      labelOf: (city) => city,
    );
    if (cities != null) _apply(_filters.copyWith(cities: cities));
  }

  Future<void> _pickShifts() async {
    final shifts = await showChoiceSheet<WorkShift>(
      context,
      title: 'Smena',
      options: WorkShift.values,
      selected: _filters.shifts,
      labelOf: (shift) => shift.label,
      iconOf: (shift) => shift.icon,
    );
    if (shifts != null) _apply(_filters.copyWith(shifts: shifts));
  }

  Future<void> _pickPayTypes() async {
    final payTypes = await showChoiceSheet<PayType>(
      context,
      title: 'Način isplate',
      options: PayType.values,
      selected: _filters.payTypes,
      labelOf: (pay) => pay.label,
      iconOf: (pay) => pay.icon,
    );
    if (payTypes != null) _apply(_filters.copyWith(payTypes: payTypes));
  }

  Future<void> _openAllFilters() async {
    final filters = await showAllFiltersSheet(context, _filters);
    if (filters != null) _apply(filters);
  }

  Future<void> _pickSort() async {
    final sort = await showSortSheet(context, _filters.sort);
    if (sort != null) _apply(_filters.copyWith(sort: sort));
  }

  void _clearAll() {
    _search.clear();
    _apply(JobFilters(sort: _filters.sort));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const JoblyTopBar(),
          const SliverToBoxAdapter(
            child: LargeTitle(title: 'Pronađi posao', subtitle: 'Studentski i omladinski poslovi'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: JobSearchField(
                controller: _search,
                onChanged: (query) => _apply(_filters.copyWith(query: query)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CategoryStories(
              selected: _filters.categories,
              onToggle: (category) => _apply(_filters.copyWith(categories: _toggled(_filters.categories, category))),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedFrostedBar(
              child: _FilterBar(
                filters: _filters,
                onAll: _openAllFilters,
                onCities: _pickCities,
                onShifts: _pickShifts,
                onPayTypes: _pickPayTypes,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _ResultsRow(count: _jobCount, sort: _filters.sort, onSort: _pickSort),
          ),
          if (_filters.hasActiveFilters)
            SliverToBoxAdapter(
              child: _ActiveFilters(filters: _filters, onChanged: _apply, onClearAll: _clearAll),
            ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              child: _filters.isNarrowed
                  ? EmptyView(
                      icon: Icons.search_off_rounded,
                      title: 'Nema oglasa za ovu pretragu',
                      message: 'Probaj sa drugim gradom, smenom ili satnicom.',
                      action: OutlinedButton(onPressed: _clearAll, child: const Text('Poništi filtere')),
                    )
                  : const EmptyView(
                      icon: Icons.work_outline_rounded,
                      title: 'Oglasi stižu uskoro',
                      message: 'Kad poslodavci objave poslove, videćeš ih ovde.',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filters,
    required this.onAll,
    required this.onCities,
    required this.onShifts,
    required this.onPayTypes,
  });

  final JobFilters filters;
  final VoidCallback onAll;
  final VoidCallback onCities;
  final VoidCallback onShifts;
  final VoidCallback onPayTypes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        JoblyChip(label: 'Filteri', icon: Icons.tune_rounded, count: filters.activeCount, onTap: onAll),
        const SizedBox(width: 8),
        JoblyChip(label: 'Grad', count: filters.cities.length, showChevron: true, onTap: onCities),
        const SizedBox(width: 8),
        JoblyChip(label: 'Smena', count: filters.shifts.length, showChevron: true, onTap: onShifts),
        const SizedBox(width: 8),
        JoblyChip(label: 'Isplata', count: filters.payTypes.length, showChevron: true, onTap: onPayTypes),
      ],
    );
  }
}

class _ResultsRow extends StatelessWidget {
  const _ResultsRow({required this.count, required this.sort, required this.onSort});

  final int count;
  final JobSort sort;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count ${pluralize(count, one: 'oglas', few: 'oglasa', many: 'oglasa')}',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Semantics(
            button: true,
            label: 'Sortiranje: ${sort.label}',
            child: ExcludeSemantics(
              child: TextButton.icon(
                onPressed: onSort,
                icon: const Icon(Icons.swap_vert_rounded, size: 20),
                label: Text(sort.label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.filters, required this.onChanged, required this.onClearAll});

  final JobFilters filters;
  final ValueChanged<JobFilters> onChanged;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    Set<T> without<T>(Set<T> set, T value) => {...set}..remove(value);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final city in filters.cities)
            RemovableTag(
              label: city,
              onRemove: () => onChanged(filters.copyWith(cities: without(filters.cities, city))),
            ),
          for (final shift in filters.shifts)
            RemovableTag(
              label: shift.label,
              onRemove: () => onChanged(filters.copyWith(shifts: without(filters.shifts, shift))),
            ),
          for (final pay in filters.payTypes)
            RemovableTag(
              label: pay.label,
              onRemove: () => onChanged(filters.copyWith(payTypes: without(filters.payTypes, pay))),
            ),
          for (final category in filters.categories)
            RemovableTag(
              label: category.label,
              onRemove: () => onChanged(filters.copyWith(categories: without(filters.categories, category))),
            ),
          if (filters.minHourlyPay > 0)
            RemovableTag(
              label: 'od ${filters.minHourlyPay} RSD/h',
              onRemove: () => onChanged(filters.copyWith(minHourlyPay: 0)),
            ),
          TextButton(onPressed: onClearAll, child: const Text('Obriši sve')),
        ],
      ),
    );
  }
}
