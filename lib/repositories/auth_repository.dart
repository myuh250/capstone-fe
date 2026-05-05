import '../models/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> logout();
  Future<void> verifyEmail(String otp);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({required String otp, required String newPassword});
  Future<User?> getCurrentUser();
}

class FakeAuthRepository implements AuthRepository {
  User? _currentUser;

  static const _fakeAdmin = User(
    id: 'admin_1',
    email: 'admin@manga.com',
    displayName: 'Admin',
    role: UserRole.admin,
    status: UserStatus.active,
    isPremium: true,
  );

  static const _fakeUser = User(
    id: 'user_1',
    email: 'user@manga.com',
    displayName: 'Manga Reader',
    role: UserRole.user,
    status: UserStatus.active,
    isPremium: false,
  );

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'admin@manga.com') {
      _currentUser = _fakeAdmin;
    } else {
      _currentUser = _fakeUser.copyWith(email: email);
    }
    return _currentUser!;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      role: UserRole.user,
      status: UserStatus.pending,
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<void> verifyEmail(String otp) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (otp != '123456') {
      throw Exception('OTP không hợp lệ');
    }
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(status: UserStatus.active);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp != '123456') {
      throw Exception('OTP không hợp lệ');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser;
  }
}
