import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return RealNotificationRepository(ref.watch(apiClientProvider));
});

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationItem>>>(
  (ref) => NotificationsNotifier(ref.read(notificationRepositoryProvider)),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).valueOrNull
      ?.where((n) => !n.isRead)
      .length ?? 0;
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final NotificationRepository _repo;

  Future<void> _load() async {
    try {
      final notifications = await _repo.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    state = AsyncValue.data(
      state.valueOrNull
              ?.map((n) => n.id == id ? n.copyWith(isRead: true) : n)
              .toList() ??
          [],
    );
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    state = AsyncValue.data(
      state.valueOrNull?.map((n) => n.copyWith(isRead: true)).toList() ?? [],
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}
