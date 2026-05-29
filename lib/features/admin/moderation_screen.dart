import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/report.dart';
import '../../providers/admin_providers.dart';
import '../../providers/moderation_providers.dart';
import '../../repositories/admin_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/confirm_action_dialog.dart';
import 'widgets/report_card.dart';

class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Moderation'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            isScrollable: true,
            tabs: [
              Tab(text: 'AI Flagged'),
              Tab(text: 'Pending'),
              Tab(text: 'Comments'),
              Tab(text: 'Manga'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AiFlaggedTab(),
            _ModerationTab(status: ReportStatus.pending),
            _ModerationTab(type: ReportType.comment),
            _ModerationTab(type: ReportType.manga),
          ],
        ),
      ),
    );
  }
}

// ─── AI Flagged Tab ───

class _AiFlaggedTab extends ConsumerWidget {
  const _AiFlaggedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(aiModerationPendingProvider);

    return pendingAsync.when(
      loading: () => const _ModerationSkeleton(),
      error: (e, _) => ErrorView(
        message: 'Failed to load AI-flagged content',
        onRetry: () => ref.invalidate(aiModerationPendingProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.verified_user_outlined,
            message: 'No content pending AI moderation review',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
          itemBuilder: (_, i) => _AiFlaggedCard(
            result: items[i],
            onApprove: () => _handleApprove(context, ref, items[i]),
            onRemove: () => _handleRemove(context, ref, items[i]),
          ),
        );
      },
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    AiModerationResult result,
  ) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Approve Content',
      message:
          'Mark this content as safe? The flag will be removed and the comment will remain visible.',
      confirmLabel: 'Approve',
    );
    if (!confirmed) return;

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.approveAiFlag(result.id);
      ref.invalidate(aiModerationPendingProvider);
      ref.invalidate(aiModerationStatsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content approved'),
            backgroundColor: AppColors.statusGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRemove(
    BuildContext context,
    WidgetRef ref,
    AiModerationResult result,
  ) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Remove Content',
      message:
          'Delete this comment permanently? The author will be notified that their content was removed.',
      confirmLabel: 'Remove',
      isDangerous: true,
    );
    if (!confirmed) return;

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.removeAiFlaggedContent(result.id);
      ref.invalidate(aiModerationPendingProvider);
      ref.invalidate(aiModerationStatsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content removed'),
            backgroundColor: AppColors.statusGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _AiFlaggedCard extends StatelessWidget {
  const _AiFlaggedCard({
    required this.result,
    required this.onApprove,
    required this.onRemove,
  });

  final AiModerationResult result;
  final VoidCallback onApprove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final classification = result.classification.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: author + classification badge
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
              const Gap(AppSpacing.xs),
              Expanded(
                child: Text(
                  result.commentAuthor ?? 'Unknown',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _ClassificationBadge(classification: classification),
            ],
          ),
          const Gap(AppSpacing.sm),

          // Comment content
          Text(
            result.commentContent ?? '(No content)',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppSpacing.sm),

          // Action description + timestamp
          Row(
            children: [
              const Icon(Icons.auto_fix_high, size: 14, color: AppColors.warning),
              const Gap(AppSpacing.xs),
              Expanded(
                child: Text(
                  'Auto-flagged for review',
                  style: const TextStyle(color: AppColors.warning, fontSize: 12),
                ),
              ),
              if (result.createdAt != null)
                Text(
                  dateFormat.format(result.createdAt!),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
            ],
          ),
          const Gap(AppSpacing.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusGreen,
                    side: const BorderSide(color: AppColors.statusGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassificationBadge extends StatelessWidget {
  const _ClassificationBadge({required this.classification});

  final String classification;

  Color get _badgeColor {
    switch (classification) {
      case 'SAFE':
        return AppColors.statusGreen;
      case 'TOXIC':
        return AppColors.error;
      case 'SPAM':
        return AppColors.warning;
      case 'NSFW':
        return AppColors.error;
      case 'SPOILER':
        return AppColors.ratingYellow;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        classification,
        style: TextStyle(
          color: _badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Reports Tabs (existing) ───

class _ModerationTab extends ConsumerWidget {
  const _ModerationTab({this.status, this.type});

  final ReportStatus? status;
  final ReportType? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return reportsAsync.when(
      loading: () => const _ModerationSkeleton(),
      error: (e, _) => ErrorView(
        message: 'Failed to load moderation content',
        onRetry: () => ref.invalidate(reportsProvider),
      ),
      data: (allReports) {
        final reports = allReports.where((r) {
          if (status != null && r.status != status) return false;
          if (type != null && r.type != type) return false;
          return true;
        }).toList();

        if (reports.isEmpty) {
          return const EmptyState(
            icon: Icons.check_circle_outline,
            message: 'All reports have been handled or there is no content to moderate',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: reports.length,
          separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
          itemBuilder: (_, i) {
            final report = reports[i];
            return ReportCard(
              report: report,
              onTap: () => context.push(
                '${RouteNames.adminReports}/${report.id}',
              ),
            );
          },
        );
      },
    );
  }
}

class _ModerationSkeleton extends StatelessWidget {
  const _ModerationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 4,
        separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
        itemBuilder: (_, __) => Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    );
  }
}
