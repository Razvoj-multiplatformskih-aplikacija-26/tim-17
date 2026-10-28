import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../models/job_filters.dart';

class CategoryStories extends StatelessWidget {
  const CategoryStories({super.key, required this.selected, required this.onToggle});

  final Set<JobCategory> selected;
  final ValueChanged<JobCategory> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: JobCategory.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = JobCategory.values[index];
          return _Story(category: category, selected: selected.contains(category), onTap: () => onToggle(category));
        },
      ),
    );
  }
}

class _Story extends StatelessWidget {
  const _Story({required this.category, required this.selected, required this.onTap});

  final JobCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobly = theme.jobly;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Kategorija ${category.label}',
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 72,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68,
                  height: 68,
                  padding: EdgeInsets.all(selected ? 3 : 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected ? jobly.gradient : null,
                    color: selected ? null : jobly.separator,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.surface),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: jobly.fill),
                      child: selected
                          ? GradientMask(child: Icon(category.icon, size: 26))
                          : Icon(category.icon, size: 26, color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
