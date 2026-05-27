import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/download_providers.dart';
import '../../../providers/subscription_providers.dart';

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
    final isPremium = ref.watch(isPremiumProvider);
    final downloads = ref.watch(downloadsProvider);
    final existing = downloads
        .where((d) => d.chapterId == chapterId)
        .firstOrNull;

    if (existing != null) {
      return switch (existing.status) {
        DownloadStatus.completed => IconButton(
            icon: const Icon(Icons.download_done, color: AppColors.statusGreen),
            tooltip: 'Downloaded',
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
            tooltip: 'Resume',
            onPressed: () => ref
                .read(downloadsProvider.notifier)
                .resumeDownload(existing.id),
          ),
        DownloadStatus.queued => const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        _ => IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.error),
            tooltip: 'Retry',
            onPressed: () => _startDownload(ref),
          ),
      };
    }

    return IconButton(
      icon: Icon(
        Icons.download_outlined,
        color: AppColors.textSecondary,
      ),
      tooltip: 'Download',
      onPressed: () {
        if (!isPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premium subscription required for offline reading'),
            ),
          );
          return;
        }
        _startDownload(ref);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading chapter...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _startDownload(WidgetRef ref) {
    ref.read(downloadsProvider.notifier).startDownload(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverUrl: coverUrl,
      chapterId: chapterId,
      chapterTitle: chapterTitle,
    );
  }
}
