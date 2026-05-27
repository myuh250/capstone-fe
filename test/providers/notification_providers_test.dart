import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/models/notification_item.dart';
import 'package:frontend/providers/notification_providers.dart';
import 'package:frontend/repositories/notification_repository.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepo;

  setUp(() {
    mockRepo = MockNotificationRepository();
  });

  List<NotificationItem> _sampleNotifications() {
    return [
      NotificationItem(
        id: '1',
        type: NotificationType.newChapter,
        title: 'New Chapter',
        body: 'Chapter 10 is out',
        createdAt: DateTime.utc(2024, 1, 1),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.commentReply,
        title: 'Reply',
        body: 'Someone replied',
        createdAt: DateTime.utc(2024, 1, 2),
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.system,
        title: 'System',
        body: 'Maintenance',
        createdAt: DateTime.utc(2024, 1, 3),
        isRead: false,
      ),
    ];
  }

  group('NotificationsNotifier', () {
    test('loads notifications on init', () async {
      final notifications = _sampleNotifications();
      when(() => mockRepo.getNotifications())
          .thenAnswer((_) async => notifications);

      final notifier = NotificationsNotifier(mockRepo);

      // Wait for the async _load to complete
      await Future.delayed(Duration.zero);

      expect(notifier.state.valueOrNull, notifications);
      verify(() => mockRepo.getNotifications()).called(1);
    });

    test('handles load error', () async {
      when(() => mockRepo.getNotifications())
          .thenThrow(Exception('Network error'));

      final notifier = NotificationsNotifier(mockRepo);

      await Future.delayed(Duration.zero);

      expect(notifier.state.hasError, true);
    });

    test('markAsRead() updates state', () async {
      final notifications = _sampleNotifications();
      when(() => mockRepo.getNotifications())
          .thenAnswer((_) async => notifications);
      when(() => mockRepo.markAsRead('1')).thenAnswer((_) async {});

      final notifier = NotificationsNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      await notifier.markAsRead('1');

      final updatedList = notifier.state.valueOrNull!;
      expect(updatedList.firstWhere((n) => n.id == '1').isRead, true);
      expect(updatedList.firstWhere((n) => n.id == '2').isRead, true);
      expect(updatedList.firstWhere((n) => n.id == '3').isRead, false);
      verify(() => mockRepo.markAsRead('1')).called(1);
    });

    test('markAllAsRead() marks all as read', () async {
      final notifications = _sampleNotifications();
      when(() => mockRepo.getNotifications())
          .thenAnswer((_) async => notifications);
      when(() => mockRepo.markAllAsRead()).thenAnswer((_) async {});

      final notifier = NotificationsNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      await notifier.markAllAsRead();

      final updatedList = notifier.state.valueOrNull!;
      expect(updatedList.every((n) => n.isRead), true);
      verify(() => mockRepo.markAllAsRead()).called(1);
    });
  });

  group('unreadCountProvider', () {
    test('returns 0 when all notifications are read', () async {
      final notifications = [
        NotificationItem(
          id: '1',
          type: NotificationType.system,
          title: 'Test',
          body: 'Body',
          createdAt: DateTime.utc(2024, 1, 1),
          isRead: true,
        ),
      ];
      when(() => mockRepo.getNotifications())
          .thenAnswer((_) async => notifications);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await Future.delayed(Duration.zero);

      final count = container.read(unreadCountProvider);
      expect(count, 0);
    });

    test('returns 0 when notifications are still loading', () {
      when(() => mockRepo.getNotifications())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 10));
        return [];
      });

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final count = container.read(unreadCountProvider);
      expect(count, 0);
    });
  });
}
