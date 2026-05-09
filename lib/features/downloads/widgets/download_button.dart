import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/download_providers.dart';

class DownloadButton extends ConsumerWidget {
  const DownloadButton({
    super.key,
    required this.mangaId,
    required this.mangaTitle,
    required this.coverUrl,
    required this.chapterId,
    required this.chapterTitle,
    this.compact = false,
  });

  final String mangaId;
  final String mangaTitle;
  final String coverUrl;
  final String chapterId;
  final String chapterTitle;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    final existing = downloads
        .where((d) => d.chapterId == chapterId)
        .firstOrNull;

    if (existing != null) {
      return switch (existing.status) {
        DownloadStatus.completed => IconButton(
            icon: const Icon(Icons.download_done, color: AppColors.statusGreen),
            tooltip: 'Đã tải',
            onPressed: () => ref
                .read(downloadsProvider.notifier)
                .removeDownload(existing.id),
          ),
        DownloadStatus.downloading => SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: existing.progress,
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(downloadsProvider.notifier)
                      .pauseDownload(existing.id),
                  child: const Icon(
                    Icons.pause,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        DownloadStatus.paused => IconButton(
            icon: const Icon(Icons.download_outlined,
                color: AppColors.textSecondary),
            tooltip: 'Tiếp tục tải',
            onPressed: () => ref
                .read(downloadsProvider.notifier)
                .resumeDownload(existing.id),
          ),
        _ => const SizedBox.shrink(),
      };
    }

    return IconButton(
      icon: const Icon(Icons.download_outlined, color: AppColors.textSecondary),
      tooltip: 'Tải xuống',
      onPressed: () {
        ref.read(downloadsProvider.notifier).addDownload(
              DownloadItem(
                mangaId: mangaId,
                mangaTitle: mangaTitle,
                coverUrl: coverUrl,
                chapterId: chapterId,
                chapterTitle: chapterTitle,
                status: DownloadStatus.downloading,
                totalPages: 48,
              ),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang tải xuống chương...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
