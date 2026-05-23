import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/report.dart';
import 'ai_flag_badge.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: report.isOverdue
              ? Border.all(color: AppColors.error.withAlpha(100))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TypeBadge(type: report.type),
                const Gap(AppSpacing.sm),
                _ReasonBadge(reason: report.reason),
                if (report.aiDetected && report.aiConfidence != null) ...[
                  const Gap(AppSpacing.sm),
                  AIFlagBadge(
                    confidence: report.aiConfidence!,
                    compact: true,
                  ),
                ],
                const Spacer(),
                _StatusBadge(status: report.status),
              ],
            ),
            if (report.isOverdue) ...[
              const Gap(AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 12, color: AppColors.error),
                  const SizedBox(width: 3),
                  Text(
                    'Unresolved for over 48h',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (report.targetTitle != null) ...[
              const Gap(AppSpacing.sm),
              Text(
                report.targetTitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (report.description != null) ...[
              const Gap(AppSpacing.xs),
              Text(
                report.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Gap(AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 3),
                Text(
                  'Reported by ${report.reportedBy}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(report.reportedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final ReportType type;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      ReportType.comment => (AppColors.statusBlue, Icons.chat_bubble_outline),
      ReportType.manga => (AppColors.primary, Icons.menu_book_outlined),
      ReportType.user => (AppColors.warning, Icons.person_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            type.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonBadge extends StatelessWidget {
  const _ReasonBadge({required this.reason});

  final ReportReason reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        reason.label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ReportStatus.pending => (AppColors.warning, 'Pending'),
      ReportStatus.resolved => (AppColors.statusGreen, 'Resolved'),
      ReportStatus.dismissed => (AppColors.textSecondary, 'Dismissed'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
