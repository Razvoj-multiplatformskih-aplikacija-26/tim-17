import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/job_filters.dart';

Future<Set<T>?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required Set<T> selected,
  required String Function(T option) labelOf,
  IconData Function(T option)? iconOf,
}) {
  return _showSheet<Set<T>>(
    context,
    (context) => _ChoiceSheet<T>(title: title, options: options, selected: selected, labelOf: labelOf, iconOf: iconOf),
  );
}

Future<JobFilters?> showAllFiltersSheet(BuildContext context, JobFilters filters) {
  return _showSheet<JobFilters>(context, (context) => _AllFiltersSheet(filters: filters));
}

Future<JobSort?> showSortSheet(BuildContext context, JobSort current) {
  return _showSheet<JobSort>(context, (context) => _SortSheet(current: current));
}

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      child: SafeArea(top: false, child: builder(context)),
    ),
  );
}

class _ChoiceSheet<T> extends StatefulWidget {
  const _ChoiceSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
    this.iconOf,
  });

  final String title;
  final List<T> options;
  final Set<T> selected;
  final String Function(T option) labelOf;
  final IconData Function(T option)? iconOf;

  @override
  State<_ChoiceSheet<T>> createState() => _ChoiceSheetState<T>();
}

class _ChoiceSheetState<T> extends State<_ChoiceSheet<T>> {
  late final Set<T> _picked = {...widget.selected};

  void _toggle(T option) => setState(() => _picked.contains(option) ? _picked.remove(option) : _picked.add(option));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(
          title: widget.title,
          onReset: () => setState(_picked.clear),
          onDone: () => Navigator.pop(context, _picked),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _GroupedList(
              children: [
                for (final option in widget.options)
                  _CheckRow(
                    label: widget.labelOf(option),
                    icon: widget.iconOf?.call(option),
                    checked: _picked.contains(option),
                    onTap: () => _toggle(option),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AllFiltersSheet extends StatefulWidget {
  const _AllFiltersSheet({required this.filters});

  final JobFilters filters;

  @override
  State<_AllFiltersSheet> createState() => _AllFiltersSheetState();
}

class _AllFiltersSheetState extends State<_AllFiltersSheet> {
  late JobFilters _filters = widget.filters;

  Set<T> _toggled<T>(Set<T> set, T value) => set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  void _update(JobFilters filters) => setState(() => _filters = filters);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minPay = _filters.minHourlyPay;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(
          title: 'Filteri',
          onReset: () => _update(_filters.cleared()),
          onDone: () => Navigator.pop(context, _filters),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Section(
                  title: 'Grad',
                  child: _ChipWrap(
                    children: [
                      for (final city in serbianCities)
                        JoblyChip(
                          label: city,
                          selected: _filters.cities.contains(city),
                          onTap: () => _update(_filters.copyWith(cities: _toggled(_filters.cities, city))),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Smena',
                  child: _ChipWrap(
                    children: [
                      for (final shift in WorkShift.values)
                        JoblyChip(
                          label: shift.label,
                          icon: shift.icon,
                          selected: _filters.shifts.contains(shift),
                          onTap: () => _update(_filters.copyWith(shifts: _toggled(_filters.shifts, shift))),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Način isplate',
                  child: _ChipWrap(
                    children: [
                      for (final pay in PayType.values)
                        JoblyChip(
                          label: pay.label,
                          icon: pay.icon,
                          selected: _filters.payTypes.contains(pay),
                          onTap: () => _update(_filters.copyWith(payTypes: _toggled(_filters.payTypes, pay))),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Kategorija',
                  child: _ChipWrap(
                    children: [
                      for (final category in JobCategory.values)
                        JoblyChip(
                          label: category.label,
                          icon: category.icon,
                          selected: _filters.categories.contains(category),
                          onTap: () => _update(_filters.copyWith(categories: _toggled(_filters.categories, category))),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Minimalna satnica',
                  trailing: Text(
                    minPay == 0 ? 'Bilo koja' : 'od $minPay RSD/h',
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
                  ),
                  child: Slider(
                    value: minPay.toDouble(),
                    max: JobFilters.maxHourlyPay.toDouble(),
                    divisions: JobFilters.maxHourlyPay ~/ JobFilters.hourlyPayStep,
                    label: minPay == 0 ? 'Bilo koja' : '$minPay RSD',
                    onChanged: (value) => _update(_filters.copyWith(minHourlyPay: value.round())),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});

  final JobSort current;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Sortiraj po', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _GroupedList(
              children: [
                for (final sort in JobSort.values)
                  _CheckRow(
                    label: sort.label,
                    icon: sort.icon,
                    checked: sort == current,
                    onTap: () => Navigator.pop(context, sort),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Zaglavlje panela kao na iOS-u: „Poništi“ levo, naslov u sredini, „Gotovo“ desno.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onReset, required this.onDone});

  final String title;
  final VoidCallback onReset;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          TextButton(onPressed: onReset, child: const Text('Poništi')),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          ),
          TextButton(
            onPressed: onDone,
            child: Text('Gotovo', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Grupisana lista sa zaobljenim uglovima i tankim linijama između redova.
class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainer;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: background,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(indent: 52), children[i]],
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.checked, required this.onTap, this.icon});

  final String label;
  final bool checked;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      selected: checked,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: icon == null ? null : Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: checked ? 1 : 0,
                child: Icon(Icons.check_rounded, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: children);
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
