import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/chapter.dart';

class ChapterListTile extends StatelessWidget {
  const ChapterListTile({
    super.key,
    required this.chapter,
    required this.onTap,
  });

  final Chapter chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        chapter.displayNumber,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: chapter.isRead
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                      ),
                      if (chapter.isEarlyAccess) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _EarlyAccessBadge(),
                      ],
                    ],
                  ),
                  if (chapter.title != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      chapter.title!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (chapter.publishedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(chapter.publishedAt!),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (chapter.isRead)
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.textSecondary,
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} năm trước';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    return 'Vừa cập nhật';
  }
}

class _EarlyAccessBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.ratingYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.ratingYellow.withOpacity(0.5),
        ),
      ),
      child: const Text(
        'Early Access',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.ratingYellow,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
