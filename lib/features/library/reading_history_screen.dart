import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/library_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/history_list_tile.dart';

class ReadingHistoryScreen extends ConsumerWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);
    final continueAsync = ref.watch(continueReadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          historyAsync.maybeWhen(
            data: (list) => list.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmClearAll(context, ref),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: AppColors.error),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const _HistorySkeleton(),
        error: (e, _) => ErrorView(
          message: 'Failed to load reading history',
          onRetry: () => ref.invalidate(readingHistoryProvider),
        ),
        data: (history) {
          if (history.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              message: 'Start reading manga to see your history here',
            );
          }
          return ListView(
            children: [
              continueAsync.maybeWhen(
                data: (recent) => recent != null
                    ? ContinueReadingCard(
                        history: recent,
                        onTap: () => context.push(
                          RouteNames.reader(
                            RouteNames.titleToSlug(recent.mangaTitle),
                            recent.lastChapterNumber,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xs,
                ),
                child: Text(
                  'ALL (${history.length})',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: AppSpacing.lg + 56 + AppSpacing.md,
                  color: AppColors.divider,
                ),
                itemBuilder: (_, i) {
                  final h = history[i];
                  return HistoryListTile(
                    history: h,
                    onTap: () => context.push(
                      RouteNames.reader(RouteNames.titleToSlug(h.mangaTitle), h.lastChapterNumber),
                    ),
                    onRemove: h.id != null
                        ? () => ref
                            .read(readingHistoryProvider.notifier)
                            .removeEntry(h.id!)
                        : null,
                  );
                },
              ),
              const Gap(AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Clear Reading History'),
        content: const Text('Are you sure you want to clear all reading history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // In a real app this would call a clearAll on the notifier
    }
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: 6,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, color: AppColors.surfaceAlt),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 12,
                      width: 120,
                      color: AppColors.surfaceAlt,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 4,
                      color: AppColors.surfaceAlt,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
