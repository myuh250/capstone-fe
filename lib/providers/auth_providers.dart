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
  AuthNotifier(this._repository) : super(const AsyncValue.data(null)) {
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
