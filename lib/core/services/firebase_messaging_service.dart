import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final instance = FirebaseMessagingService._();

  final _messaging = FirebaseMessaging.instance;
  String? _deviceToken;

  String? get deviceToken => _deviceToken;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _deviceToken = await _messaging.getToken();
      debugPrint('FCM Token: $_deviceToken');
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    _messaging.onTokenRefresh.listen((token) {
      _deviceToken = token;
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground notification: ${message.notification?.title}');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Opened from notification: ${message.data}');
  }
}
