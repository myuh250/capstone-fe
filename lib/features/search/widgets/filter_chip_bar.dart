import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/manga.dart';
import '../../../providers/search_providers.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.filters,
    required this.onFilterTap,
    required this.onSortTap,
  });

  final SearchFilters filters;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        filters.genres.isNotEmpty || filters.status != null;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          Center(
            child: _FilterButton(
              icon: Icons.tune,
              label: 'Filter',
              isActive: hasActiveFilters,
              onTap: onFilterTap,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Center(
            child: _FilterButton(
              icon: Icons.sort,
              label: _sortLabel(filters.sortBy),
              isActive: filters.sortBy != 'relevance',
              onTap: onSortTap,
            ),
          ),
          if (filters.status != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Center(
              child: _ActiveFilterChip(
                label: _statusLabel(filters.status!),
                onRemove: null,
              ),
            ),
          ],
          ...filters.genres.map((g) {
            return Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Center(
                child: _ActiveFilterChip(label: g, onRemove: null),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _statusLabel(MangaStatus status) => switch (status) {
        MangaStatus.ongoing => 'Ongoing',
        MangaStatus.completed => 'Completed',
        MangaStatus.hiatus => 'Hiatus',
        MangaStatus.cancelled => 'Cancelled',
      };

  String _sortLabel(String sortBy) => switch (sortBy) {
        'rating' => 'Highest Rated',
        'title' => 'Title A-Z',
        'latest' => 'Latest',
        _ => 'Sort',
      };
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

