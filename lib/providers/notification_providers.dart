import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  (ref) => NotificationsNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super(_fakeNotifications);

  static final _now = DateTime.now();

  static final List<NotificationItem> _fakeNotifications = [
    NotificationItem(
      id: 'n1',
      type: NotificationType.newChapter,
      title: 'One Piece - Chương 1089',
      body: 'Chương mới của One Piece vừa được phát hành. Đọc ngay!',
      createdAt: _now.subtract(const Duration(minutes: 15)),
      isRead: false,
      imageUrl:
          'https://uploads.mangadex.org/covers/a1c7c817-4e59-43b7-9365-09675a149a6f/1a5a20b4-05d9-4b77-9f85-7be7f21dc490.jpg',
      targetId: '1',
    ),
    NotificationItem(
      id: 'n2',
      type: NotificationType.commentReply,
      title: 'MinhAnh đã trả lời bình luận của bạn',
      body: '"Đồng ý với bạn! Mình cũng vừa đọc xong và cảm thấy rất tuyệt vời."',
      createdAt: _now.subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      type: NotificationType.newChapter,
      title: 'Chainsaw Man - Chương 146',
      body: 'Chương mới của Chainsaw Man đã có mặt. Bỏ lỡ không?',
      createdAt: _now.subtract(const Duration(hours: 5)),
      isRead: false,
      imageUrl:
          'https://uploads.mangadex.org/covers/a77742b1-befd-49a4-bff5-1ad4e6b328d5/07656d79-f2d8-49c7-a27d-0b7e4e8e3a50.jpg',
      targetId: '12',
    ),
    NotificationItem(
      id: 'n4',
      type: NotificationType.system,
      title: 'Chào mừng đến MangaApp!',
      body:
          'Khám phá hàng nghìn manga miễn phí. Đăng ký Premium để trải nghiệm tốt hơn.',
      createdAt: _now.subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n5',
      type: NotificationType.subscription,
      title: 'Gói Premium sắp hết hạn',
      body:
          'Gói Premium của bạn sẽ hết hạn sau 3 ngày. Gia hạn ngay để không gián đoạn.',
      createdAt: _now.subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationItem(
      id: 'n6',
      type: NotificationType.newChapter,
      title: 'Hunter x Hunter - Chương 401',
      body: 'Sau nhiều năm chờ đợi, Hunter x Hunter trở lại với chương mới!',
      createdAt: _now.subtract(const Duration(days: 3)),
      isRead: true,
      imageUrl:
          'https://uploads.mangadex.org/covers/2f5f3c84-5a44-43de-baaf-2fcd6a11e3ab/7dc3b75f-8e5e-4c9b-b1b0-3dce8cd48ee2.jpg',
      targetId: '10',
    ),
  ];

  void markAsRead(String id) {
    state = state
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}
