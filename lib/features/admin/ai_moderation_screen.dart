import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/admin_providers.dart';
import '../../repositories/admin_repository.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';

class AiModerationScreen extends ConsumerStatefulWidget {
  const AiModerationScreen({super.key});

  @override
  ConsumerState<AiModerationScreen> createState() =>
      _AiModerationScreenState();
}

class _AiModerationScreenState extends ConsumerState<AiModerationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(aiModerationStatsProvider);
    ref.invalidate(aiModerationResultsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Moderation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'All Results'),
            Tab(text: 'Flagged Only'),
          ],
        ),
      ),
      body: Column(
        children: [
          const _StatsHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ResultsList(flaggedOnly: false),
                _ResultsList(flaggedOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Header ───

class _StatsHeader extends ConsumerWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(aiModerationStatsProvider);

    return statsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: LoadingSkeleton(width: double.infinity, height: 72),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: LoadingSkeleton(width: double.infinity, height: 72),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: LoadingSkeleton(width: double.infinity, height: 72),
            ),
          ],
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Failed to load stats',
          style: TextStyle(color: AppColors.error),
        ),
      ),
      data: (stats) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Analyzed',
                value: stats.totalAnalyzed.toString(),
                icon: Icons.analytics_outlined,
                color: AppColors.statusBlue,
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Flagged',
                value: stats.totalFlagged.toString(),
                icon: Icons.flag_outlined,
                color: AppColors.error,
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: 'Safe',
                value: stats.safeCount.toString(),
                icon: Icons.check_circle_outline,
                color: AppColors.statusGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Results List ───

class _ResultsList extends ConsumerWidget {
  const _ResultsList({required this.flaggedOnly});

  final bool flaggedOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(aiModerationResultsProvider(flaggedOnly));

    return resultsAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
        itemBuilder: (_, __) => LoadingSkeleton(
          width: double.infinity,
          height: 100,
        ),
      ),
      error: (e, _) => ErrorView(
        message: 'Failed to load moderation results',
        onRetry: () => ref.invalidate(aiModerationResultsProvider),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const Gap(AppSpacing.lg),
                Text(
                  flaggedOnly
                      ? 'No flagged content found'
                      : 'No moderation results yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: results.length,
          separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
          itemBuilder: (_, i) => _ResultCard(result: results[i]),
        );
      },
    );
  }
}

// ─── Result Card ───

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final AiModerationResult result;

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
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const Gap(AppSpacing.xs),
              Expanded(
                child: Text(
                  result.commentAuthor ?? 'Unknown',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
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
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppSpacing.md),

          // Bottom row: action + timestamp
          Row(
            children: [
              if (result.actionTaken) ...[
                Icon(
                  Icons.gavel,
                  size: 14,
                  color: AppColors.warning,
                ),
                const Gap(AppSpacing.xs),
                Expanded(
                  child: Text(
                    result.actionDescription ?? 'Action taken',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.remove_circle_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const Gap(AppSpacing.xs),
                Expanded(
                  child: Text(
                    'No action',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              if (result.createdAt != null)
                Text(
                  dateFormat.format(result.createdAt!),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Classification Badge ───

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
        color: _badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: _badgeColor.withOpacity(0.4)),
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
