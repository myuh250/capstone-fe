import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/local_storage.dart';
import '../models/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
    String? otp,
  });
  Future<User> googleLogin({required String idToken});
  Future<void> logout();
  Future<void> sendRegistrationOtp(String email);
  Future<void> verifyEmail(String otp);
  Future<void> forgotPassword(String email);
  Future<bool> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({required String email, required String otp, required String newPassword});
  Future<User?> getCurrentUser();
  Future<User> updateProfile({String? displayName, String? bio});
  Future<String> uploadAvatar(Uint8List bytes, String filename);
  Future<User> removeAvatar();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class RealAuthRepository implements AuthRepository {
  RealAuthRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final LocalStorage _storage;

  /// Backend returns a flat auth payload (tokens + username/email/role), not a nested `user`.
  Future<User> _sessionFromAuthResponse(Map<String, dynamic> data) async {
    await _storage.saveAccessToken(data['accessToken'] as String);
    await _storage.saveRefreshToken(data['refreshToken'] as String);
    final user = await getCurrentUser();
    if (user == null) {
      throw StateError('Failed to load user profile after authentication');
    }
    return user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return _sessionFromAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> sendRegistrationOtp(String email) async {
    await _apiClient.post(
      ApiEndpoints.registerOtp,
      data: {'email': email},
    );
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
    String? otp,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'otp': otp,
      },
    );
    return _sessionFromAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<User> googleLogin({required String idToken}) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleLogin,
      data: {'idToken': idToken},
    );
    return _sessionFromAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      await _apiClient.post(
        ApiEndpoints.logout,
        data: {'refreshToken': refreshToken},
      );
    }
    await _storage.clearTokens();
  }

  @override
  Future<void> verifyEmail(String otp) async {
    await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {'otp': otp},
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return true;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    final response = await _apiClient.get(ApiEndpoints.profile);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<User> updateProfile({String? displayName, String? bio}) async {
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName;
    if (bio != null) data['bio'] = bio;
    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: data,
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> uploadAvatar(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _apiClient.post(
      '/users/me/avatar',
      data: formData,
    );
    return (response.data as Map<String, dynamic>)['avatarUrl'] as String;
  }

  @override
  Future<User> removeAvatar() async {
    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: {'avatarUrl': ''},
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
