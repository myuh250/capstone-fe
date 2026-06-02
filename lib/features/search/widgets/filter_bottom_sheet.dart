import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/manga.dart';
import '../../../providers/search_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  bool _genresExpanded = false;
  static const _collapsedCount = 12;

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final notifier = ref.read(searchFiltersProvider.notifier);
    final genresAsync = ref.watch(allGenresProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _SheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: notifier.reset,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _SectionLabel(label: 'Status'),
                  const Gap(AppSpacing.md),
                  _StatusFilterRow(
                    selected: filters.status,
                    onSelect: notifier.setStatus,
                  ),
                  const Gap(AppSpacing.xl),
                  _SectionLabel(label: 'Genre'),
                  const Gap(AppSpacing.md),
                  genresAsync.when(
                    data: (genres) => _GenreSelector(
                      genres: genres,
                      selectedGenres: filters.genres,
                      onToggle: notifier.toggleGenre,
                      expanded: _genresExpanded,
                      collapsedCount: _collapsedCount,
                      onToggleExpand: () =>
                          setState(() => _genresExpanded = !_genresExpanded),
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const Text('Failed to load genres'),
                  ),
                  const Gap(AppSpacing.xl),
                  _SectionLabel(label: 'Sort'),
                  const Gap(AppSpacing.md),
                  ...sortOptions.map((opt) {
                    final isSelected = filters.sortBy == opt.$1;
                    return RadioListTile<String>(
                      value: opt.$1,
                      groupValue: filters.sortBy,
                      onChanged: (v) {
                        if (v != null) notifier.setSortBy(v);
                      },
                      title: Text(opt.$2),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      selected: isSelected,
                    );
                  }),
                  const Gap(AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg + MediaQuery.of(context).padding.bottom,
              ),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GenreSelector extends StatelessWidget {
  const _GenreSelector({
    required this.genres,
    required this.selectedGenres,
    required this.onToggle,
    required this.expanded,
    required this.collapsedCount,
    required this.onToggleExpand,
  });

  final List<String> genres;
  final List<String> selectedGenres;
  final void Function(String) onToggle;
  final bool expanded;
  final int collapsedCount;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final visible = expanded ? genres : genres.take(collapsedCount).toList();
    final hasMore = genres.length > collapsedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: visible.map((genre) {
            final isSelected = selectedGenres.contains(genre);
            return FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (_) => onToggle(genre),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              backgroundColor: AppColors.surfaceAlt,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            );
          }).toList(),
        ),
        if (hasMore) ...[
          const Gap(AppSpacing.sm),
          GestureDetector(
            onTap: onToggleExpand,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  expanded
                      ? 'Show less'
                      : 'Show all (${genres.length})',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
    );
  }
}

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.selected, required this.onSelect});

  final MangaStatus? selected;
  final void Function(MangaStatus?) onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatusChip(
          label: 'All',
          isSelected: selected == null,
          onTap: () => onSelect(null),
        ),
        _StatusChip(
          label: 'Ongoing',
          isSelected: selected == MangaStatus.ongoing,
          onTap: () => onSelect(MangaStatus.ongoing),
        ),
        _StatusChip(
          label: 'Completed',
          isSelected: selected == MangaStatus.completed,
          onTap: () => onSelect(MangaStatus.completed),
        ),
        _StatusChip(
          label: 'Hiatus',
          isSelected: selected == MangaStatus.hiatus,
          onTap: () => onSelect(MangaStatus.hiatus),
        ),
        _StatusChip(
          label: 'Cancelled',
          isSelected: selected == MangaStatus.cancelled,
          onTap: () => onSelect(MangaStatus.cancelled),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
