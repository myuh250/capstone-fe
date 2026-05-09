import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/report.dart';
import '../../providers/moderation_providers.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/ai_flag_badge.dart';
import 'widgets/moderation_action_bar.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết báo cáo'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: reportAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Không thể tải báo cáo',
          onRetry: () => ref.invalidate(reportDetailProvider(reportId)),
        ),
        data: (report) => _ReportDetailContent(report: report),
      ),
    );
  }
}

class _ReportDetailContent extends ConsumerStatefulWidget {
  const _ReportDetailContent({required this.report});

  final Report report;

  @override
  ConsumerState<_ReportDetailContent> createState() =>
      _ReportDetailContentState();
}

class _ReportDetailContentState
    extends ConsumerState<_ReportDetailContent> {
  bool _isLoading = false;

  Future<void> _resolveReport() async {
    final reason = await _showReasonDialog(
      context,
      title: 'Xử lý báo cáo',
      hint: 'Nhập lý do xử lý...',
      submitLabel: 'Xử lý',
      submitColor: AppColors.statusGreen,
    );
    if (reason == null) return;
    setState(() => _isLoading = true);
    await ref.read(reportsProvider.notifier).resolveReport(
          widget.report.id,
          reason,
        );
    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  Future<void> _dismissReport() async {
    final reason = await _showReasonDialog(
      context,
      title: 'Bỏ qua báo cáo',
      hint: 'Nhập lý do bỏ qua...',
      submitLabel: 'Bỏ qua',
      submitColor: AppColors.textSecondary,
    );
    if (reason == null) return;
    setState(() => _isLoading = true);
    await ref.read(reportsProvider.notifier).dismissReport(
          widget.report.id,
          reason,
        );
    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  Future<String?> _showReasonDialog(
    BuildContext context, {
    required String title,
    required String hint,
    required String submitLabel,
    required Color submitColor,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(
              controller.text.trim().isNotEmpty
                  ? controller.text.trim()
                  : 'Không có ghi chú',
            ),
            style: FilledButton.styleFrom(backgroundColor: submitColor),
            child: Text(submitLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final isPending = report.status == ReportStatus.pending;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _InfoSection(
                title: 'Thông tin báo cáo',
                children: [
                  _InfoRow(
                    label: 'Loại nội dung',
                    value: report.type.label,
                  ),
                  _InfoRow(label: 'Lý do', value: report.reason.label),
                  _InfoRow(
                    label: 'Báo cáo bởi',
                    value: report.reportedBy,
                  ),
                  _InfoRow(
                    label: 'Thời gian',
                    value: _formatDate(report.reportedAt),
                  ),
                  _InfoRow(
                    label: 'Trạng thái',
                    value: report.status.label,
                    valueColor: _statusColor(report.status),
                  ),
                  if (report.isOverdue)
                    _InfoRow(
                      label: 'Cảnh báo',
                      value: 'Quá 48h chưa xử lý',
                      valueColor: AppColors.error,
                    ),
                ],
              ),
              const Gap(AppSpacing.lg),
              if (report.aiDetected && report.aiConfidence != null) ...[
                const Gap(AppSpacing.lg),
                AIFlagBadge(confidence: report.aiConfidence!),
              ],
              if (report.targetTitle != null)
                _InfoSection(
                  title: 'Nội dung bị báo cáo',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Text(
                              report.targetTitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                          if (report.description != null) ...[
                            const Gap(AppSpacing.sm),
                            Text(
                              'Mô tả từ người báo cáo:',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const Gap(AppSpacing.xs),
                            Text(
                              report.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              if (!isPending && report.resolution != null) ...[
                const Gap(AppSpacing.lg),
                _InfoSection(
                  title: 'Kết quả xử lý',
                  children: [
                    _InfoRow(
                      label: 'Xử lý bởi',
                      value: report.resolvedBy ?? '-',
                    ),
                    _InfoRow(
                      label: 'Thời gian xử lý',
                      value: report.resolvedAt != null
                          ? _formatDate(report.resolvedAt!)
                          : '-',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ghi chú:',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: AppColors.textSecondary),
                          ),
                          const Gap(AppSpacing.xs),
                          Text(
                            report.resolution!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (isPending)
          ModerationActionBar(
            onResolve: _resolveReport,
            onDismiss: _dismissReport,
            onWarn: report.type == ReportType.user ||
                    report.type == ReportType.comment
                ? () {}
                : null,
            onBan: report.type == ReportType.user ? () {} : null,
            isLoading: _isLoading,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(ReportStatus status) => switch (status) {
        ReportStatus.pending => AppColors.warning,
        ReportStatus.resolved => AppColors.statusGreen,
        ReportStatus.dismissed => AppColors.textSecondary,
      };
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
