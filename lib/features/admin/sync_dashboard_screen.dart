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

class _SyncJobDef {
  const _SyncJobDef({
    required this.jobType,
    required this.label,
    required this.description,
    required this.icon,
    this.defaultCron = '',
    this.hasLimit = false,
    this.defaultLimit = 20,
  });

  final String jobType;
  final String label;
  final String description;
  final IconData icon;
  final String defaultCron;
  final bool hasLimit;
  final int defaultLimit;
}

const _allSyncJobs = [
  _SyncJobDef(
    jobType: 'TRENDING_SYNC',
    label: 'Trending Sync',
    description: 'Fetch top recently-updated manga from MangaDex',
    icon: Icons.trending_up,
    defaultCron: '0 0 2 * * *',
    hasLimit: true,
    defaultLimit: 20,
  ),
  _SyncJobDef(
    jobType: 'CHAPTER_SYNC',
    label: 'Chapter Sync',
    description: 'Check for new chapters for all tracked manga',
    icon: Icons.menu_book,
    defaultCron: '0 0 */6 * * *',
  ),
  _SyncJobDef(
    jobType: 'RATING_SYNC',
    label: 'Rating Sync',
    description: 'Fetch MangaDex ratings for manga missing ratings',
    icon: Icons.star_outline,
    defaultCron: '0 5 2 * * *',
  ),
  _SyncJobDef(
    jobType: 'GENRE_SYNC',
    label: 'Genre Sync',
    description: 'Assign genres from MangaDex to manga without genres',
    icon: Icons.category_outlined,
    defaultCron: '',
  ),
];

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
          _buildJobsSection(context, dashboard.configs),
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
      ],
    );
  }

  // ─── Jobs Section ───

  Widget _buildJobsSection(BuildContext context, List<SyncConfig> configs) {
    final configMap = {for (var c in configs) c.jobType: c};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync Jobs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.lg),
        ..._allSyncJobs.map((job) {
          final config = configMap[job.jobType];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _SyncJobCard(
              job: job,
              config: config,
              onTrigger: () => _showTriggerDialog(job, config),
              onToggle: config != null
                  ? (enabled) => _updateConfig(config, enabled)
                  : null,
            ),
          );
        }),
      ],
    );
  }

  // ─── Logs Section ───

  Widget _buildLogsSection(BuildContext context, List<SyncConfig> configs) {
    final logsAsync = ref.watch(syncLogsProvider(_selectedJobTypeFilter));

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
            _buildJobTypeFilter(),
          ],
        ),
        const Gap(AppSpacing.lg),
        logsAsync.when(
          data: (logs) => _buildLogsList(logs),
          loading: () =>
              const LoadingSkeleton(width: double.infinity, height: 200),
          error: (e, _) => ErrorView(
            message: 'Failed to load sync logs.',
            onRetry: () =>
                ref.invalidate(syncLogsProvider(_selectedJobTypeFilter)),
          ),
        ),
      ],
    );
  }

  Widget _buildJobTypeFilter() {
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
            ..._allSyncJobs.map(
              (job) => DropdownMenuItem<String?>(
                value: job.jobType,
                child: Text(job.label, style: const TextStyle(fontSize: 13)),
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

  void _showTriggerDialog(_SyncJobDef job, SyncConfig? config) {
    showDialog(
      context: context,
      builder: (_) => _TriggerSyncDialog(
        job: job,
        config: config,
        onConfirm: (cronExpression, enabled, limit) async {
          if (config != null &&
              (cronExpression != config.cronExpression ||
                  enabled != config.enabled)) {
            final repo = ref.read(adminRepositoryProvider);
            await repo.updateSyncConfig(
              jobType: job.jobType,
              cronExpression: cronExpression,
              enabled: enabled,
            );
          }
          await _triggerSync(job.jobType, limit: limit);
        },
      ),
    );
  }

  Future<void> _triggerSync(String jobType, {int? limit}) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.triggerSync(jobType, limit: limit);

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

// ─── Trigger Sync Dialog ───

class _TriggerSyncDialog extends StatefulWidget {
  const _TriggerSyncDialog({
    required this.job,
    required this.config,
    required this.onConfirm,
  });

  final _SyncJobDef job;
  final SyncConfig? config;
  final Future<void> Function(String cronExpression, bool enabled, int? limit) onConfirm;

  @override
  State<_TriggerSyncDialog> createState() => _TriggerSyncDialogState();
}

class _TriggerSyncDialogState extends State<_TriggerSyncDialog> {
  late final TextEditingController _cronController;
  late final TextEditingController _limitController;
  late bool _enabled;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _cronController = TextEditingController(
      text: widget.config?.cronExpression ?? widget.job.defaultCron,
    );
    _limitController = TextEditingController(
      text: widget.job.hasLimit ? '${widget.job.defaultLimit}' : '',
    );
    _enabled = widget.config?.enabled ?? true;
  }

  @override
  void dispose() {
    _cronController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _onRun() async {
    setState(() => _isRunning = true);
    try {
      final limit = widget.job.hasLimit
          ? int.tryParse(_limitController.text.trim())
          : null;
      await widget.onConfirm(_cronController.text.trim(), _enabled, limit);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastRun = widget.config?.lastRunTime;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Icon(widget.job.icon, color: AppColors.primary, size: 24),
          const Gap(AppSpacing.sm),
          Expanded(child: Text(widget.job.label)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job.description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const Gap(AppSpacing.lg),

            // Last run info
            if (lastRun != null) ...[
              _InfoRow(
                label: 'Last Run',
                value: dateFormat.format(lastRun.toLocal()),
              ),
              const Gap(AppSpacing.sm),
            ],
            if (widget.config?.lastRunStatus != null) ...[
              _InfoRow(
                label: 'Last Status',
                value: widget.config!.lastRunStatus!.toUpperCase(),
                valueColor: _colorForStatus(widget.config!.lastRunStatus!),
              ),
              const Gap(AppSpacing.lg),
            ],

            // Cron expression
            const Text(
              'Schedule (Cron Expression)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const Gap(AppSpacing.sm),
            TextFormField(
              controller: _cronController,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0 0 */6 * * *',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
            const Gap(AppSpacing.md),

            // Limit field (only for jobs that support it)
            if (widget.job.hasLimit) ...[
              const Gap(AppSpacing.md),
              const Text(
                'Limit (number of items to fetch)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Gap(AppSpacing.sm),
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '${widget.job.defaultLimit}',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ],
            const Gap(AppSpacing.md),

            // Enabled toggle
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Auto-schedule enabled',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                Switch(
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isRunning ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isRunning ? null : _onRun,
          icon: _isRunning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.play_arrow, size: 18),
          label: Text(_isRunning ? 'Running...' : 'Run Now'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Sync Job Card ───

class _SyncJobCard extends StatelessWidget {
  const _SyncJobCard({
    required this.job,
    required this.config,
    required this.onTrigger,
    required this.onToggle,
  });

  final _SyncJobDef job;
  final SyncConfig? config;
  final VoidCallback onTrigger;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final isEnabled = config?.enabled ?? false;
    final lastRun = config?.lastRunTime;
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(job.icon, color: AppColors.primary, size: 22),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      job.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (config?.lastRunStatus != null) ...[
                      const Gap(AppSpacing.sm),
                      _StatusChip(status: config!.lastRunStatus!),
                    ],
                  ],
                ),
                const Gap(AppSpacing.xs),
                Text(
                  job.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (config != null) ...[
                  const Gap(AppSpacing.xs),
                  Text(
                    'Schedule: ${config!.cronExpression.isNotEmpty ? config!.cronExpression : "Manual only"}  •  Last: ${lastRun != null ? dateFormat.format(lastRun.toLocal()) : "Never"}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (onToggle != null)
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: AppColors.primary,
            ),
          const Gap(AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 22),
            tooltip: 'Configure & Run',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              foregroundColor: AppColors.primary,
            ),
            onPressed: onTrigger,
          ),
        ],
      ),
    );
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
              color: color.withValues(alpha: 0.15),
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

    final duration =
        log.durationMs != null ? _formatDuration(log.durationMs!) : '—';

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
        color: color.withValues(alpha: 0.15),
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
