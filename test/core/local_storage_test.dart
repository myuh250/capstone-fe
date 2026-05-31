import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/core/storage/local_storage.dart';

void main() {
  late LocalStorage localStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorage(prefs);
  });

  group('LocalStorage', () {
    group('access token', () {
      test('saveAccessToken and getAccessToken', () async {
        await localStorage.saveAccessToken('test-token');
        final result = await localStorage.getAccessToken();
        expect(result, 'test-token');
      });

      test('getAccessToken returns null when not set', () async {
        final result = await localStorage.getAccessToken();
        expect(result, isNull);
      });
    });

    group('refresh token', () {
      test('saveRefreshToken and getRefreshToken', () async {
        await localStorage.saveRefreshToken('refresh-abc');
        final result = await localStorage.getRefreshToken();
        expect(result, 'refresh-abc');
      });

      test('getRefreshToken returns null when not set', () async {
        final result = await localStorage.getRefreshToken();
        expect(result, isNull);
      });
    });

    group('clearTokens', () {
      test('removes both tokens', () async {
        await localStorage.saveAccessToken('access');
        await localStorage.saveRefreshToken('refresh');

        await localStorage.clearTokens();

        expect(await localStorage.getAccessToken(), isNull);
        expect(await localStorage.getRefreshToken(), isNull);
      });
    });

    group('theme mode', () {
      test('saveThemeMode and getThemeMode', () async {
        await localStorage.saveThemeMode('dark');
        final result = await localStorage.getThemeMode();
        expect(result, 'dark');
      });

      test('getThemeMode returns null when not set', () async {
        final result = await localStorage.getThemeMode();
        expect(result, isNull);
      });
    });

    group('onboarding', () {
      test('isOnboardingCompleted defaults to false', () async {
        final result = await localStorage.isOnboardingCompleted();
        expect(result, false);
      });

      test('setOnboardingCompleted sets to true', () async {
        await localStorage.setOnboardingCompleted();
        final result = await localStorage.isOnboardingCompleted();
        expect(result, true);
      });
    });

    group('clear', () {
      test('removes all data', () async {
        await localStorage.saveAccessToken('token');
        await localStorage.saveThemeMode('light');
        await localStorage.setOnboardingCompleted();

        await localStorage.clear();

        expect(await localStorage.getAccessToken(), isNull);
        expect(await localStorage.getThemeMode(), isNull);
        expect(await localStorage.isOnboardingCompleted(), false);
      });
    });
  });
}
