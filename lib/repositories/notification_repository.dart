import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/notification_item.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotifications({bool unreadOnly = false});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> registerDeviceToken(String fcmToken, String deviceId);
  Future<void> removeDeviceToken(String deviceId);
}

class RealNotificationRepository implements NotificationRepository {
  RealNotificationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<NotificationItem>> getNotifications({
    bool unreadOnly = false,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: unreadOnly ? {'unreadOnly': true} : null,
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(
      ApiEndpoints.notificationsUnreadCount,
    );
    final data = response.data;
    if (data is int) return data;
    if (data is Map<String, dynamic>) {
      return data['count'] as int? ?? 0;
    }
    return 0;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _apiClient.put(ApiEndpoints.notificationMarkRead(id));
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.put(ApiEndpoints.notificationsReadAll);
  }

  @override
  Future<void> registerDeviceToken(String fcmToken, String deviceId) async {
    await _apiClient.post(
      ApiEndpoints.notificationDeviceToken,
      data: {'fcmToken': fcmToken, 'deviceId': deviceId},
    );
  }

  @override
  Future<void> removeDeviceToken(String deviceId) async {
    await _apiClient.delete(
      ApiEndpoints.notificationDeviceTokenDelete(deviceId),
    );
  }
}
