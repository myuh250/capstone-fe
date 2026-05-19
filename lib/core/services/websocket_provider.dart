import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage.dart';
import 'websocket_service.dart';

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final storage = ref.watch(localStorageProvider);
  final service = WebSocketService(storage);
  ref.onDispose(() => service.dispose());
  return service;
});
