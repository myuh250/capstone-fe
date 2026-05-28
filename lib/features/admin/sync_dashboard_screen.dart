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
import 'widgets/confirm_action_dialog.dart';

class SyncDashboardScreen extends ConsumerStatefulWidget {
  const SyncDashboardScreen({super.key});

  @override
  ConsumerState<SyncDashboardScreen> createState() =>
      _SyncDashboardScreenState();
}

class _SyncDashboardScreenState extends ConsumerState<SyncDashboardScreen> {
  String? _selectedJobTypeFilter;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(syncDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => _buildContent(context, dashboard),
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: LoadingSkeleton(width: double.infinity, height: 400),
        ),
        error: (e, _) => ErrorView(
          message: 'Failed to load sync dashboard.',
          onRetry: _refreshAll,
        ),
      ),
    );
  }

  void _refreshAll() {
    ref.invalidate(syncDashboardProvider);
    ref.invalidate(syncLogsProvider(_selectedJobTypeFilter));
  }

  Widget _buildContent(BuildContext context, SyncDashboard dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSection(context, dashboard),
          const Gap(AppSpacing.xl),
          _buildConfigsSection(context, dashboard.configs),
          const Gap(AppSpacing.xl),
          _buildLogsSection(context, dashboard.configs),
        ],
      ),
    );
  }

  // ─── Overview Section ───

  Widget _buildOverviewSection(BuildContext context, SyncDashboard dashboard) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final lastSync = dashboard.lastSyncTime != null
        ? dateFormat.format(dashboard.lastSyncTime!.toLocal())
        : 'Never';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _OverviewCard(
              icon: Icons.sync,
              label: 'Total Syncs',
              value: '${dashboard.totalSyncs}',
              color: AppColors.statusBlue,
            ),
            _OverviewCard(
              icon: Icons.check_circle_outline,
              label: 'Successful',
              value: '${dashboard.successCount}',
              color: AppColors.statusGreen,
            ),
            _OverviewCard(
              icon: Icons.error_outline,
              label: 'Failed',
              value: '${dashboard.failedCount}',
              color: AppColors.error,
            ),
            _OverviewCard(
              icon: Icons.access_time,
              label: 'Last Sync',
              value: lastSync,
              color: AppColors.primary,
            ),
          ],
        ),
        if (dashboard.lastSyncStatus != null) ...[
          const Gap(AppSpacing.md),
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              _StatusChip(status: dashboard.lastSyncStatus!),
            ],
          ),
        ],
      ],
    );
  }

  // ─── Configs Section ───

  Widget _buildConfigsSection(BuildContext context, List<SyncConfig> configs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync Configurations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.lg),
        if (configs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Text(
              'No sync configurations found.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...configs.map((config) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _SyncConfigCard(
                  config: config,
                  onToggle: (enabled) => _updateConfig(config, enabled),
                  onTrigger: () => _triggerSync(config.jobType),
                ),
              )),
      ],
    );
  }

  // ─── Logs Section ───

  Widget _buildLogsSection(BuildContext context, List<SyncConfig> configs) {
    final logsAsync = ref.watch(syncLogsProvider(_selectedJobTypeFilter));

    final jobTypes = configs.map((c) => c.jobType).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Sync Logs',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            _buildJobTypeFilter(jobTypes),
          ],
        ),
        const Gap(AppSpacing.lg),
        logsAsync.when(
          data: (logs) => _buildLogsList(logs),
          loading: () => const LoadingSkeleton(width: double.infinity, height: 200),
          error: (e, _) => ErrorView(
            message: 'Failed to load sync logs.',
            onRetry: () =>
                ref.invalidate(syncLogsProvider(_selectedJobTypeFilter)),
          ),
        ),
      ],
    );
  }

  Widget _buildJobTypeFilter(List<String> jobTypes) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedJobTypeFilter,
          hint: const Text(
            'All Jobs',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          isDense: true,
          dropdownColor: AppColors.surface,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Jobs', style: TextStyle(fontSize: 13)),
            ),
            ...jobTypes.map(
              (type) => DropdownMenuItem<String?>(
                value: type,
                child: Text(type, style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedJobTypeFilter = value);
          },
        ),
      ),
    );
  }

  Widget _buildLogsList(List<SyncLog> logs) {
    if (logs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Text(
          'No sync logs found.',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          for (int i = 0; i < logs.length; i++) ...[
            _SyncLogTile(log: logs[i]),
            if (i < logs.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  // ─── Actions ───

  Future<void> _triggerSync(String jobType) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Trigger Sync',
      message: 'Are you sure you want to trigger a "$jobType" sync now?',
      confirmLabel: 'Trigger',
      isDangerous: false,
    );

    if (!confirmed || !mounted) return;

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.triggerSync(jobType);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync "$jobType" triggered successfully.'),
          backgroundColor: AppColors.statusGreen,
        ),
      );
      _refreshAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to trigger sync: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateConfig(SyncConfig config, bool enabled) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.updateSyncConfig(
        jobType: config.jobType,
        cronExpression: config.cronExpression,
        enabled: enabled,
      );
      ref.invalidate(syncDashboardProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update config: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// ─── Overview Card ───

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Gap(AppSpacing.md),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Sync Config Card ───

class _SyncConfigCard extends StatelessWidget {
  const _SyncConfigCard({
    required this.config,
    required this.onToggle,
    required this.onTrigger,
  });

  final SyncConfig config;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTrigger;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    final lastRun = config.lastRunTime != null
        ? dateFormat.format(config.lastRunTime!.toLocal())
        : 'Never';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      config.jobType,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (config.lastRunStatus != null) ...[
                      const Gap(AppSpacing.sm),
                      _StatusChip(status: config.lastRunStatus!),
                    ],
                  ],
                ),
                const Gap(AppSpacing.xs),
                Text(
                  'Cron: ${config.cronExpression}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                ),
                const Gap(AppSpacing.xs),
                Text(
                  'Last run: $lastRun',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: config.enabled,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
          const Gap(AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 20),
            tooltip: 'Trigger Sync Now',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.15),
              foregroundColor: AppColors.primary,
            ),
            onPressed: onTrigger,
          ),
        ],
      ),
    );
  }
}

// ─── Sync Log Tile ───

class _SyncLogTile extends StatelessWidget {
  const _SyncLogTile({required this.log});

  final SyncLog log;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm:ss');
    final timestamp = log.startedAt != null
        ? dateFormat.format(log.startedAt!.toLocal())
        : '—';

    final duration = log.durationMs != null
        ? _formatDuration(log.durationMs!)
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _StatusDot(status: log.status),
          const Gap(AppSpacing.md),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.jobType,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(AppSpacing.xs),
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.summary ?? '—',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              duration,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int ms) {
    if (ms < 1000) return '${ms}ms';
    final seconds = ms / 1000;
    if (seconds < 60) return '${seconds.toStringAsFixed(1)}s';
    final minutes = seconds / 60;
    return '${minutes.toStringAsFixed(1)}m';
  }
}

// ─── Status Chip ───

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Status Dot ───

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── Helpers ───

Color _colorForStatus(String status) {
  switch (status.toLowerCase()) {
    case 'success':
    case 'completed':
      return AppColors.statusGreen;
    case 'running':
    case 'in_progress':
      return AppColors.statusBlue;
    case 'failed':
    case 'error':
      return AppColors.error;
    default:
      return AppColors.textSecondary;
  }
}
