import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${(diff.inDays / 7).floor()} tuần trước';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: notification.isRead
              ? Colors.transparent
              : AppColors.primary.withAlpha(15),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotifIcon(
                type: notification.type,
                imageUrl: notification.imageUrl,
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const Gap(2),
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      _formatDate(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.type, this.imageUrl});

  final NotificationType type;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Image.network(
          imageUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackIcon(type: type),
        ),
      );
    }
    return _FallbackIcon(type: type);
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      NotificationType.newChapter =>
        (Icons.auto_stories, AppColors.primary),
      NotificationType.commentReply =>
        (Icons.chat_bubble_outline, AppColors.statusBlue),
      NotificationType.system =>
        (Icons.campaign_outlined, AppColors.warning),
      NotificationType.subscription =>
        (Icons.workspace_premium_outlined, AppColors.ratingYellow),
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
