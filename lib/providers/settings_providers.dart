import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/local_storage.dart';

// Theme

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(localStorageProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.dark) {
    _load();
  }

  final LocalStorage _storage;

  Future<void> _load() async {
    final saved = await _storage.getThemeMode();
    if (saved == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggle() async {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await _storage.saveThemeMode('light');
    } else {
      state = ThemeMode.dark;
      await _storage.saveThemeMode('dark');
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

// Notification preferences

class NotificationPreferences {
  const NotificationPreferences({
    this.allEnabled = true,
    this.newChapter = true,
    this.commentReplies = true,
    this.system = true,
  });

  final bool allEnabled;
  final bool newChapter;
  final bool commentReplies;
  final bool system;

  NotificationPreferences copyWith({
    bool? allEnabled,
    bool? newChapter,
    bool? commentReplies,
    bool? system,
  }) {
    return NotificationPreferences(
      allEnabled: allEnabled ?? this.allEnabled,
      newChapter: newChapter ?? this.newChapter,
      commentReplies: commentReplies ?? this.commentReplies,
      system: system ?? this.system,
    );
  }
}

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier(ref.read(apiClientProvider));
});

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier(this._apiClient)
      : super(const NotificationPreferences()) {
    _load();
  }

  final ApiClient _apiClient;

  Future<void> _load() async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.notificationPreferences);
      final data = response.data as Map<String, dynamic>;
      state = NotificationPreferences(
        allEnabled: true,
        newChapter: data['newChapterEnabled'] as bool? ?? true,
        commentReplies: data['mentionEnabled'] as bool? ?? true,
        system: data['systemEnabled'] as bool? ?? true,
      );
    } catch (_) {}
  }

  Future<void> setAll(bool enabled) async {
    state = state.copyWith(
      allEnabled: enabled,
      newChapter: enabled,
      commentReplies: enabled,
      system: enabled,
    );
    await _save();
  }

  Future<void> setNewChapter(bool enabled) async {
    state = state.copyWith(newChapter: enabled);
    await _save();
  }

  Future<void> setCommentReplies(bool enabled) async {
    state = state.copyWith(commentReplies: enabled);
    await _save();
  }

  Future<void> setSystem(bool enabled) async {
    state = state.copyWith(system: enabled);
    await _save();
  }

  Future<void> _save() async {
    try {
      await _apiClient.put(
        ApiEndpoints.notificationPreferences,
        data: {
          'newChapterEnabled': state.newChapter,
          'mentionEnabled': state.commentReplies,
          'systemEnabled': state.system,
        },
      );
    } catch (_) {}
  }
}
