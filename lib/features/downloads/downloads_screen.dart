import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/download_providers.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/empty_state.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Reading'),
      ),
      body: downloads.isEmpty
          ? const EmptyState(
              icon: Icons.download_outlined,
              message:
                  'No downloaded manga yet\nDownload chapters to read offline',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'Downloaded (${downloads.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Gap(AppSpacing.md),
                ...downloads.map(
                  (d) => _DownloadTile(
                    item: d,
                    onTap: () {
                      if (d.status == DownloadStatus.completed) {
                        final slug = RouteNames.titleToSlug(d.mangaTitle);
                        final chapterNum = _extractChapterNumber(d.chapterTitle);
                        context.push(RouteNames.reader(slug, chapterNum));
                      }
                    },
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

  double _extractChapterNumber(String chapterTitle) {
    final match = RegExp(r'Ch\.?(\d+\.?\d*)').firstMatch(chapterTitle);
    if (match != null) return double.tryParse(match.group(1)!) ?? 1.0;
    return 1.0;
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
  });

  final DownloadItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                      _StatusRow(item: item),
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
                    '${item.downloadedPages}/${item.totalPages} pages',
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
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context) {
    final (color, text) = switch (item.status) {
      DownloadStatus.completed => (AppColors.statusGreen, 'Downloaded'),
      DownloadStatus.downloading => (AppColors.primary, 'Downloading...'),
      DownloadStatus.paused => (AppColors.warning, 'Paused'),
      DownloadStatus.queued => (AppColors.textSecondary, 'Queued'),
      DownloadStatus.failed => (AppColors.error, 'Failed'),
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
