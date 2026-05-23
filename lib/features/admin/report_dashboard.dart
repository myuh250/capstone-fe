import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/moderation_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/report_card.dart';
import 'widgets/report_filter_bar.dart';

class ReportDashboard extends ConsumerWidget {
  const ReportDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(reportsProvider.notifier).refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: const ReportFilterBar(),
          ),
        ),
      ),
      body: reportsAsync.when(
        loading: () => const _ReportsSkeleton(),
        error: (e, _) => ErrorView(
          message: 'Failed to load report list',
          onRetry: () => ref.invalidate(reportsProvider),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const EmptyState(
              icon: Icons.flag_outlined,
              message: 'All reports have been handled or there are no new reports',
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
      ),
    );
  }
}

class _ReportsSkeleton extends StatelessWidget {
  const _ReportsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
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
