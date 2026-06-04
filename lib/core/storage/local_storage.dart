import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_storage.g.dart';

class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _themeModeKey = 'theme_mode';
  static const _onboardingKey = 'onboarding_completed';
  static const _chatSessionKey = 'chat_session_id';
  static const _adminChatSessionKey = 'admin_chat_session_id';

  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_accessTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_chatSessionKey);
    await _prefs.remove(_adminChatSessionKey);
  }

  String? getChatSessionId() => _prefs.getString(_chatSessionKey);

  Future<void> saveChatSessionId(String sessionId) async {
    await _prefs.setString(_chatSessionKey, sessionId);
  }

  Future<void> clearChatSession() async {
    await _prefs.remove(_chatSessionKey);
  }

  String? getAdminChatSessionId() => _prefs.getString(_adminChatSessionKey);

  Future<void> saveAdminChatSessionId(String sessionId) async {
    await _prefs.setString(_adminChatSessionKey, sessionId);
  }

  Future<void> clearAdminChatSession() async {
    await _prefs.remove(_adminChatSessionKey);
  }

  Future<String?> getThemeMode() async {
    return _prefs.getString(_themeModeKey);
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
LocalStorage localStorage(LocalStorageRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return LocalStorage(prefs);
}
