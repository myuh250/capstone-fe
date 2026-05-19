import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/notification_item.dart';
import '../../providers/notification_providers.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Thông báo'),
            if (unread > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$unread mới',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (items) => items.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none,
                message: 'Bạn chưa có thông báo nào',
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.divider,
                ),
                itemBuilder: (_, i) {
                  final n = items[i];
                  return NotificationCard(
                    notification: n,
                    onTap: () {
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(n.id);
                      _handleTap(context, n);
                    },
                    onDismiss: () => ref
                        .read(notificationsProvider.notifier)
                        .markAsRead(n.id),
                  );
                },
              ),
      ),
    );
  }

  void _handleTap(BuildContext context, NotificationItem n) {
    if (n.type == NotificationType.newChapter && n.targetId != null) {
      context.push(RouteNames.mangaDetail(n.targetId!));
    }
  }
}
