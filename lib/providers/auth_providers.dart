import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RealAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(localStorageProvider),
  );
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _repository;

  Future<void> _init() async {
    final user = await _repository.getCurrentUser();
    state = AsyncValue.data(user);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> googleLogin({required String idToken}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.googleLogin(idToken: idToken);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  Future<bool> verifyEmail(String otp) async {
    try {
      await _repository.verifyEmail(otp);
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> updateProfile({String? displayName, String? bio}) async {
    final updated = await _repository.updateProfile(
      displayName: displayName,
      bio: bio,
    );
    state = AsyncValue.data(updated);
  }

  Future<void> uploadAvatar(Uint8List bytes, String filename) async {
    await _repository.uploadAvatar(bytes, filename);
    final user = await _repository.getCurrentUser();
    state = AsyncValue.data(user);
  }

  Future<void> removeAvatar() async {
    final updated = await _repository.removeAvatar();
    state = AsyncValue.data(updated);
  }

  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
    state = const AsyncValue.data(null);
  }
}

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.role == UserRole.admin;
});
