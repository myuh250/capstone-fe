import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/comment.dart';
import '../../../shared/widgets/user_avatar.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.onReply,
    this.onDelete,
    this.isReply = false,
  });

  final Comment comment;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final bool isReply;

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${(diff.inDays / 7).floor()} tuần trước';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isReply ? AppSpacing.xxl + AppSpacing.md : AppSpacing.lg,
        0,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: comment.userAvatarUrl,
            name: comment.userName,
            size: isReply ? 28 : 36,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (comment.userId == 'current_user') ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: const Text(
                          'Bạn',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _formatDate(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
                if (comment.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '(đã chỉnh sửa)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.reply_outlined,
                      label: 'Trả lời',
                      onTap: onReply,
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        label: 'Xóa',
                        onTap: onDelete!,
                        color: AppColors.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: c,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
