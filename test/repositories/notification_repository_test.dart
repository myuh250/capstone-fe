import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/repositories/notification_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late RealNotificationRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = RealNotificationRepository(mockApiClient);
  });

  group('NotificationRepository', () {
    group('getNotifications()', () {
      test('parses paginated response with content field', () async {
        final responseData = {
          'content': [
            {
              'id': '1',
              'type': 'NEW_CHAPTER',
              'title': 'New Chapter',
              'body': 'Chapter 5 is out',
              'createdAt': '2024-01-15T10:00:00Z',
              'isRead': false,
            },
            {
              'id': '2',
              'type': 'COMMENT_REPLY',
              'title': 'Reply',
              'body': 'Someone replied',
              'createdAt': '2024-01-16T12:00:00Z',
              'isRead': true,
            },
          ],
          'totalPages': 1,
          'totalElements': 2,
        };

        when(() => mockApiClient.get(
              ApiEndpoints.notifications,
              queryParameters: null,
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiEndpoints.notifications),
            ));

        final notifications = await repository.getNotifications();

        expect(notifications.length, 2);
        expect(notifications[0].id, '1');
        expect(notifications[0].title, 'New Chapter');
        expect(notifications[1].id, '2');
        expect(notifications[1].isRead, true);
      });

      test('parses list response (non-paginated)', () async {
        final responseData = [
          {
            'id': '1',
            'type': 'SYSTEM',
            'title': 'System Alert',
            'body': 'Maintenance scheduled',
            'createdAt': '2024-02-01T00:00:00Z',
            'isRead': false,
          },
        ];

        when(() => mockApiClient.get(
              ApiEndpoints.notifications,
              queryParameters: null,
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiEndpoints.notifications),
            ));

        final notifications = await repository.getNotifications();

        expect(notifications.length, 1);
        expect(notifications[0].title, 'System Alert');
      });

      test('passes unreadOnly query parameter', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.notifications,
              queryParameters: {'unreadOnly': true},
            )).thenAnswer((_) async => Response(
              data: <dynamic>[],
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiEndpoints.notifications),
            ));

        final notifications =
            await repository.getNotifications(unreadOnly: true);

        expect(notifications, isEmpty);
        verify(() => mockApiClient.get(
              ApiEndpoints.notifications,
              queryParameters: {'unreadOnly': true},
            )).called(1);
      });
    });

    group('getUnreadCount()', () {
      test('returns count from map response', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.notificationsUnreadCount,
            )).thenAnswer((_) async => Response(
              data: {'count': 5},
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.notificationsUnreadCount),
            ));

        final count = await repository.getUnreadCount();

        expect(count, 5);
      });

      test('returns int directly when response is int', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.notificationsUnreadCount,
            )).thenAnswer((_) async => Response(
              data: 3,
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.notificationsUnreadCount),
            ));

        final count = await repository.getUnreadCount();

        expect(count, 3);
      });

      test('returns 0 for unexpected response format', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.notificationsUnreadCount,
            )).thenAnswer((_) async => Response(
              data: 'unexpected',
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.notificationsUnreadCount),
            ));

        final count = await repository.getUnreadCount();

        expect(count, 0);
      });
    });

    group('markAsRead()', () {
      test('calls correct endpoint with PUT', () async {
        when(() => mockApiClient.put(
              ApiEndpoints.notificationMarkRead('notif-1'),
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.notificationMarkRead('notif-1')),
            ));

        await repository.markAsRead('notif-1');

        verify(() => mockApiClient.put(
              ApiEndpoints.notificationMarkRead('notif-1'),
            )).called(1);
      });

      test('calls endpoint /notifications/{id}/read', () async {
        const id = 'abc-123';
        final expectedPath = '/notifications/$id/read';

        when(() => mockApiClient.put(expectedPath)).thenAnswer(
            (_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: expectedPath),
                ));

        await repository.markAsRead(id);

        verify(() => mockApiClient.put(expectedPath)).called(1);
      });
    });

    group('markAllAsRead()', () {
      test('calls correct endpoint with PUT', () async {
        when(() => mockApiClient.put(
              ApiEndpoints.notificationsReadAll,
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: ApiEndpoints.notificationsReadAll),
            ));

        await repository.markAllAsRead();

        verify(() => mockApiClient.put(
              ApiEndpoints.notificationsReadAll,
            )).called(1);
      });

      test('calls endpoint /notifications/read-all', () async {
        when(() => mockApiClient.put('/notifications/read-all')).thenAnswer(
            (_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions:
                      RequestOptions(path: '/notifications/read-all'),
                ));

        await repository.markAllAsRead();

        verify(() => mockApiClient.put('/notifications/read-all')).called(1);
      });
    });
  });
}
