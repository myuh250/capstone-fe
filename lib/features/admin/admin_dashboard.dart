import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/admin_providers.dart';
import '../../repositories/admin_repository.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/responsive_builder.dart';
import 'widgets/stat_card.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => _DashboardContent(stats: stats),
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: LoadingSkeleton(width: double.infinity, height: 400),
        ),
        error: (e, _) => ErrorView(
          message: 'Failed to load statistics.',
          onRetry: () => ref.invalidate(adminStatsProvider),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Gap(AppSpacing.lg),
          ResponsiveBuilder(
            mobile: (context) => _StatsGrid(stats: stats, columns: 2),
            tablet: (context) => _StatsGrid(stats: stats, columns: 3),
            desktop: (context) => _StatsGrid(stats: stats, columns: 3),
          ),
          const Gap(AppSpacing.xl),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Gap(AppSpacing.md),
          _QuickActionsGrid(),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.columns});

  final AdminDashboardStats stats;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Total Users',
        stats.totalUsers.toString(),
        Icons.people_outline,
        AppColors.statusBlue,
        '+${stats.newUsersToday} today',
      ),
      (
        'Total Manga',
        stats.totalManga.toString(),
        Icons.menu_book_outlined,
        AppColors.primary,
        null,
      ),
      (
        'Total Chapters',
        stats.totalChapters.toString(),
        Icons.article_outlined,
        AppColors.statusGreen,
        null,
      ),
      (
        'Pending Reports',
        stats.totalReports.toString(),
        Icons.flag_outlined,
        AppColors.error,
        null,
      ),
      (
        'New Today',
        stats.newUsersToday.toString(),
        Icons.person_add_outlined,
        AppColors.statusGreen,
        null,
      ),
      (
        'Active Readers',
        stats.activeReaders.toString(),
        Icons.auto_stories_outlined,
        AppColors.ratingYellow,
        null,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return StatCard(
          label: item.$1,
          value: item.$2,
          icon: item.$3,
          color: item.$4,
          trend: item.$5,
        );
      },
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'User Management',
        Icons.manage_accounts_outlined,
        RouteNames.adminUsers,
      ),
      (
        'Content Management',
        Icons.library_books_outlined,
        RouteNames.adminContent,
      ),
      (
        'Moderation',
        Icons.shield_outlined,
        RouteNames.adminModeration,
      ),
      (
        'Reports',
        Icons.flag_outlined,
        RouteNames.adminReports,
      ),
      (
        'AI Moderation',
        Icons.smart_toy_outlined,
        RouteNames.adminAiModeration,
      ),
      (
        'Sync Dashboard',
        Icons.sync_outlined,
        RouteNames.adminSync,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionCard(
          label: action.$1,
          icon: action.$2,
          route: action.$3,
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const Gap(AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
