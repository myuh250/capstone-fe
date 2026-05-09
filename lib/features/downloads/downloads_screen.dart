import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/download_providers.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/storage_usage_indicator.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc offline'),
        actions: [
          if (downloads.isNotEmpty)
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Xóa tất cả'),
                    content: const Text(
                      'Xóa tất cả dữ liệu đã tải xuống?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  for (final d in downloads) {
                    ref.read(downloadsProvider.notifier).removeDownload(d.id);
                  }
                }
              },
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: downloads.isEmpty
          ? const EmptyState(
              icon: Icons.download_outlined,
              message:
                  'Chưa có manga nào được tải xuống\nTải manga để đọc khi không có mạng',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const StorageUsageIndicator(),
                const Gap(AppSpacing.xl),
                Text(
                  'Đã tải (${downloads.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Gap(AppSpacing.md),
                ...downloads.map(
                  (d) => _DownloadTile(
                    item: d,
                    onDelete: () => ref
                        .read(downloadsProvider.notifier)
                        .removeDownload(d.id),
                    onPause: () => ref
                        .read(downloadsProvider.notifier)
                        .pauseDownload(d.id),
                    onResume: () => ref
                        .read(downloadsProvider.notifier)
                        .resumeDownload(d.id),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({
    required this.item,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
  });

  final DownloadItem item;
  final VoidCallback onDelete;
  final VoidCallback onPause;
  final VoidCallback onResume;

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: CoverImage(
                  imageUrl: item.coverUrl,
                  width: 44,
                  height: 60,
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.mangaTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Text(
                      item.chapterTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    _StatusRow(item: item, formatBytes: _formatBytes),
                  ],
                ),
              ),
              _ActionButton(
                item: item,
                onDelete: onDelete,
                onPause: onPause,
                onResume: onResume,
              ),
            ],
          ),
          if (item.status == DownloadStatus.downloading) ...[
            const Gap(AppSpacing.sm),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: item.progress,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),
            const Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.downloadedPages}/${item.totalPages} trang',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(item.progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.item, required this.formatBytes});

  final DownloadItem item;
  final String Function(int) formatBytes;

  @override
  Widget build(BuildContext context) {
    final (color, text) = switch (item.status) {
      DownloadStatus.completed => (
          AppColors.statusGreen,
          'Hoàn thành • ${formatBytes(item.fileSizeBytes)}'
        ),
      DownloadStatus.downloading => (AppColors.primary, 'Đang tải...'),
      DownloadStatus.paused => (AppColors.warning, 'Tạm dừng'),
      DownloadStatus.queued => (AppColors.textSecondary, 'Chờ tải'),
      DownloadStatus.failed => (AppColors.error, 'Thất bại'),
    };
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.item,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
  });

  final DownloadItem item;
  final VoidCallback onDelete;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return switch (item.status) {
      DownloadStatus.completed => IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      DownloadStatus.downloading => IconButton(
          icon: const Icon(Icons.pause_circle_outline,
              color: AppColors.primary),
          onPressed: onPause,
        ),
      DownloadStatus.paused => IconButton(
          icon: const Icon(Icons.play_circle_outline,
              color: AppColors.primary),
          onPressed: onResume,
        ),
      _ => const SizedBox(width: 48),
    };
  }
}
