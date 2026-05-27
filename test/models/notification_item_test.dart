import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/notification_item.dart';

void main() {
  group('NotificationItem', () {
    group('fromJson()', () {
      test('parses NEW_CHAPTER type correctly', () {
        final json = {
          'id': '1',
          'type': 'NEW_CHAPTER',
          'title': 'New Chapter Available',
          'body': 'Chapter 10 is out!',
          'createdAt': '2024-01-15T10:30:00Z',
          'isRead': false,
          'imageUrl': 'https://example.com/image.png',
          'targetId': 'manga-123',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.id, '1');
        expect(item.type, NotificationType.newChapter);
        expect(item.title, 'New Chapter Available');
        expect(item.body, 'Chapter 10 is out!');
        expect(item.createdAt, DateTime.parse('2024-01-15T10:30:00Z'));
        expect(item.isRead, false);
        expect(item.imageUrl, 'https://example.com/image.png');
        expect(item.targetId, 'manga-123');
      });

      test('parses COMMENT_REPLY type correctly', () {
        final json = {
          'id': '2',
          'type': 'COMMENT_REPLY',
          'title': 'New Reply',
          'body': 'Someone replied to your comment',
          'createdAt': '2024-02-01T12:00:00Z',
          'isRead': true,
        };

        final item = NotificationItem.fromJson(json);

        expect(item.type, NotificationType.commentReply);
        expect(item.isRead, true);
        expect(item.imageUrl, isNull);
        expect(item.targetId, isNull);
      });

      test('parses MENTION type correctly', () {
        final json = {
          'id': '3',
          'type': 'MENTION',
          'title': 'You were mentioned',
          'body': '@user mentioned you',
          'createdAt': '2024-03-10T08:00:00Z',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.type, NotificationType.mention);
      });

      test('parses SYSTEM type correctly', () {
        final json = {
          'id': '4',
          'type': 'SYSTEM',
          'title': 'System Notice',
          'body': 'Maintenance scheduled',
          'createdAt': '2024-04-01T00:00:00Z',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.type, NotificationType.system);
      });

      test('handles null type as system', () {
        final json = {
          'id': '5',
          'type': null,
          'title': 'Unknown',
          'body': 'Some message',
          'createdAt': '2024-05-01T00:00:00Z',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.type, NotificationType.system);
      });

      test('handles unknown type as system', () {
        final json = {
          'id': '6',
          'type': 'UNKNOWN_TYPE',
          'title': 'Mystery',
          'body': 'Unknown notification',
          'createdAt': '2024-05-01T00:00:00Z',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.type, NotificationType.system);
      });

      test('maps backend field name message to body', () {
        final json = {
          'id': '7',
          'type': 'SYSTEM',
          'title': 'Test',
          'message': 'Body from message field',
          'createdAt': '2024-06-01T00:00:00Z',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.body, 'Body from message field');
      });

      test('maps backend field name read to isRead', () {
        final json = {
          'id': '8',
          'type': 'SYSTEM',
          'title': 'Test',
          'body': 'test',
          'createdAt': '2024-06-01T00:00:00Z',
          'read': true,
        };

        final item = NotificationItem.fromJson(json);

        expect(item.isRead, true);
      });

      test('maps backend field name targetUrl to targetId', () {
        final json = {
          'id': '9',
          'type': 'NEW_CHAPTER',
          'title': 'Test',
          'body': 'test',
          'createdAt': '2024-06-01T00:00:00Z',
          'targetUrl': '/manga/abc-123',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.targetId, '/manga/abc-123');
      });

      test('prefers body over message when both present', () {
        final json = {
          'id': '10',
          'type': 'SYSTEM',
          'title': 'Test',
          'body': 'Primary body',
          'message': 'Fallback message',
          'createdAt': '2024-06-01T00:00:00Z',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.body, 'Primary body');
      });

      test('prefers isRead over read when both present', () {
        final json = {
          'id': '11',
          'type': 'SYSTEM',
          'title': 'Test',
          'body': 'test',
          'createdAt': '2024-06-01T00:00:00Z',
          'isRead': true,
          'read': false,
        };

        final item = NotificationItem.fromJson(json);

        expect(item.isRead, true);
      });

      test('converts numeric id to string', () {
        final json = {
          'id': 42,
          'type': 'SYSTEM',
          'title': 'Test',
          'body': 'test',
          'createdAt': '2024-06-01T00:00:00Z',
        };

        final item = NotificationItem.fromJson(json);

        expect(item.id, '42');
      });
    });

    group('copyWith()', () {
      test('creates correct copy with changed fields', () {
        final original = NotificationItem(
          id: '1',
          type: NotificationType.newChapter,
          title: 'Original',
          body: 'Original body',
          createdAt: DateTime(2024, 1, 1),
          isRead: false,
          imageUrl: 'https://example.com/img.png',
          targetId: 'target-1',
        );

        final copy = original.copyWith(
          isRead: true,
          title: 'Updated',
        );

        expect(copy.id, '1');
        expect(copy.type, NotificationType.newChapter);
        expect(copy.title, 'Updated');
        expect(copy.body, 'Original body');
        expect(copy.isRead, true);
        expect(copy.imageUrl, 'https://example.com/img.png');
        expect(copy.targetId, 'target-1');
      });

      test('creates identical copy when no arguments provided', () {
        final original = NotificationItem(
          id: '1',
          type: NotificationType.mention,
          title: 'Test',
          body: 'Body',
          createdAt: DateTime(2024, 6, 15),
          isRead: true,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.type, original.type);
        expect(copy.title, original.title);
        expect(copy.body, original.body);
        expect(copy.createdAt, original.createdAt);
        expect(copy.isRead, original.isRead);
        expect(copy.imageUrl, original.imageUrl);
        expect(copy.targetId, original.targetId);
      });
    });
  });
}
