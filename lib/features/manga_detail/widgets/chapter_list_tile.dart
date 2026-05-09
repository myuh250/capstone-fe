import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/chapter.dart';

class ChapterListTile extends StatelessWidget {
  const ChapterListTile({
    super.key,
    required this.chapter,
    required this.onTap,
    this.isPremium = false,
  });

  final Chapter chapter;
  final VoidCallback onTap;
  final bool isPremium;

  bool get _isLocked => chapter.isEarlyAccess && !isPremium;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLocked ? () => _showPremiumGate(context) : onTap,
      child: Opacity(
        opacity: _isLocked ? 0.7 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: _isLocked
                ? AppColors.ratingYellow.withAlpha(10)
                : Colors.transparent,
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
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: chapter.isRead
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                        ),
                        if (chapter.isEarlyAccess) ...[
                          const SizedBox(width: AppSpacing.sm),
                          EarlyAccessBadge(),
                        ],
                      ],
                    ),
                    if (_isLocked) ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Nâng cấp Premium để đọc trước',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ratingYellow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (chapter.title != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        chapter.title!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
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
                              color:
                                  AppColors.textSecondary.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_isLocked)
                const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.ratingYellow,
                )
              else if (chapter.isRead)
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
      ),
    );
  }

  void _showPremiumGate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PremiumGateSheet(
        onUpgrade: () {
          Navigator.of(context).pop();
          context.push(RouteNames.premium);
        },
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

class EarlyAccessBadge extends StatelessWidget {
  const EarlyAccessBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.ratingYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.ratingYellow.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            size: compact ? 8 : 10,
            color: AppColors.ratingYellow,
          ),
          if (!compact) ...[
            const SizedBox(width: 2),
            const Text(
              'Early Access',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.ratingYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PremiumGateSheet extends StatelessWidget {
  const _PremiumGateSheet({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Nội dung Premium',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Chương này là nội dung đọc trước dành riêng cho thành viên Premium. '
                'Nâng cấp để đọc ngay hôm nay!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  onPressed: onUpgrade,
                  icon: const Icon(Icons.workspace_premium, size: 20),
                  label: const Text(
                    'Nâng cấp Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Để sau',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
