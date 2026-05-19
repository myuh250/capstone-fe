import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../network/api_endpoints.dart';
import '../storage/local_storage.dart';

class WebSocketService {
  WebSocketService(this._storage);

  final LocalStorage _storage;
  StompClient? _client;
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notifications => _notificationController.stream;

  bool get isConnected => _client?.connected ?? false;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _storage.getAccessToken();
    _client = StompClient(
      config: StompConfig.sockJS(
        url: ApiEndpoints.wsUrl,
        stompConnectHeaders: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        onConnect: _onConnect,
        onDisconnect: (_) {},
        onWebSocketError: (error) {},
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    _client!.subscribe(
      destination: '/user/queue/notifications',
      callback: (frame) {
        if (frame.body != null) {
          _notificationController.add(_parseBody(frame.body!));
        }
      },
    );
  }

  Map<String, dynamic> _parseBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'raw': body};
    }
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
