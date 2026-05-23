import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/report.dart';
import '../../../providers/moderation_providers.dart';

class ReportFilterBar extends ConsumerWidget {
  const ReportFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(reportsFilterProvider);
    final typeFilter = ref.watch(reportsTypeFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _FilterChip(
            label: 'All',
            selected: statusFilter == null,
            onTap: () => ref.read(reportsFilterProvider.notifier).state = null,
          ),
          const SizedBox(width: AppSpacing.sm),
          ...ReportStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _FilterChip(
                  label: s.label,
                  selected: statusFilter == s,
                  color: _statusColor(s),
                  onTap: () =>
                      ref.read(reportsFilterProvider.notifier).state =
                          statusFilter == s ? null : s,
                ),
              )),
          const SizedBox(width: AppSpacing.md),
          ...ReportType.values.map((t) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _FilterChip(
                  label: t.label,
                  selected: typeFilter == t,
                  onTap: () =>
                      ref.read(reportsTypeFilterProvider.notifier).state =
                          typeFilter == t ? null : t,
                ),
              )),
        ],
      ),
    );
  }

  Color _statusColor(ReportStatus status) => switch (status) {
        ReportStatus.pending => AppColors.warning,
        ReportStatus.resolved => AppColors.statusGreen,
        ReportStatus.dismissed => AppColors.textSecondary,
      };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? c.withAlpha(40) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: selected ? c : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? c : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
