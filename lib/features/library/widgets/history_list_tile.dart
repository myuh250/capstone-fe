import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/reading_history.dart';
import '../../../shared/widgets/cover_image.dart';
import 'reading_progress_bar.dart';

class HistoryListTile extends StatelessWidget {
  const HistoryListTile({
    super.key,
    required this.history,
    required this.onTap,
    this.onRemove,
  });

  final ReadingHistory history;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  String _formatDate(DateTime date) {
    final localDate = date.isUtc ? date.toLocal() : date;
    final diff = DateTime.now().difference(localDate);
    if (diff.isNegative) return 'Just now';
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoverImage(
                  imageUrl: history.coverUrl,
                  width: 56,
                  height: 80,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.mangaTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Text(
                            'Ch.${history.lastChapterNumber % 1 == 0 ? history.lastChapterNumber.toInt() : history.lastChapterNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '• ${_formatDate(history.lastReadAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.sm),
                      if (history.totalChapters > 0)
                        ReadingProgressBar(
                          chaptersRead: history.chaptersRead,
                          totalChapters: history.totalChapters,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (onRemove != null)
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close_rounded, size: 14),
                    color: AppColors.error,
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
