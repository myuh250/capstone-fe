import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/report.dart';
import '../../providers/moderation_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/report_card.dart';

class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Moderation'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Comments'),
              Tab(text: 'Manga'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ModerationTab(status: ReportStatus.pending),
            _ModerationTab(type: ReportType.comment),
            _ModerationTab(type: ReportType.manga),
          ],
        ),
      ),
    );
  }
}

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
