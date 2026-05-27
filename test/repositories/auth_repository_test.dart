import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/repositories/auth_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late MockApiClient mockApiClient;
  late MockLocalStorage mockStorage;
  late RealAuthRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockStorage = MockLocalStorage();
    repository = RealAuthRepository(mockApiClient, mockStorage);
  });

  group('AuthRepository', () {
    group('login()', () {
      test('saves tokens and returns user', () async {
        final loginResponse = {
          'accessToken': 'access-token-123',
          'refreshToken': 'refresh-token-456',
        };
        final profileResponse = {
          'id': 'user-1',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'role': 'USER',
        };

        when(() => mockApiClient.post(
              ApiEndpoints.login,
              data: {'email': 'test@example.com', 'password': 'password123'},
            )).thenAnswer((_) async => Response(
              data: loginResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiEndpoints.login),
            ));

        when(() => mockStorage.saveAccessToken('access-token-123'))
            .thenAnswer((_) async {});
        when(() => mockStorage.saveRefreshToken('refresh-token-456'))
            .thenAnswer((_) async {});
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => 'access-token-123');
        when(() => mockApiClient.get(ApiEndpoints.profile))
            .thenAnswer((_) async => Response(
                  data: profileResponse,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ApiEndpoints.profile),
                ));

        final user = await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(user.id, 'user-1');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        verify(() => mockStorage.saveAccessToken('access-token-123')).called(1);
        verify(() => mockStorage.saveRefreshToken('refresh-token-456'))
            .called(1);
      });
    });

    group('register()', () {
      test('registers with OTP and saves tokens', () async {
        final registerResponse = {
          'accessToken': 'new-access-token',
          'refreshToken': 'new-refresh-token',
        };
        final profileResponse = {
          'id': 'user-2',
          'email': 'new@example.com',
          'displayName': 'New User',
          'role': 'USER',
        };

        when(() => mockApiClient.post(
              ApiEndpoints.register,
              data: {
                'email': 'new@example.com',
                'password': 'securepass',
                'displayName': 'New User',
                'otp': '123456',
              },
            )).thenAnswer((_) async => Response(
              data: registerResponse,
              statusCode: 201,
              requestOptions: RequestOptions(path: ApiEndpoints.register),
            ));

        when(() => mockStorage.saveAccessToken('new-access-token'))
            .thenAnswer((_) async {});
        when(() => mockStorage.saveRefreshToken('new-refresh-token'))
            .thenAnswer((_) async {});
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => 'new-access-token');
        when(() => mockApiClient.get(ApiEndpoints.profile))
            .thenAnswer((_) async => Response(
                  data: profileResponse,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ApiEndpoints.profile),
                ));

        final user = await repository.register(
          email: 'new@example.com',
          password: 'securepass',
          displayName: 'New User',
          otp: '123456',
        );

        expect(user.id, 'user-2');
        expect(user.displayName, 'New User');
        verify(() => mockStorage.saveAccessToken('new-access-token')).called(1);
        verify(() => mockStorage.saveRefreshToken('new-refresh-token'))
            .called(1);
      });
    });

    group('forgotPassword()', () {
      test('calls correct endpoint with email', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.forgotPassword,
              data: {'email': 'forgot@example.com'},
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: ApiEndpoints.forgotPassword),
            ));

        await repository.forgotPassword('forgot@example.com');

        verify(() => mockApiClient.post(
              ApiEndpoints.forgotPassword,
              data: {'email': 'forgot@example.com'},
            )).called(1);
      });
    });

    group('verifyOtp()', () {
      test('calls correct endpoint with email and otp', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.verifyOtp,
              data: {'email': 'test@example.com', 'otp': '654321'},
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiEndpoints.verifyOtp),
            ));

        final result = await repository.verifyOtp(
          email: 'test@example.com',
          otp: '654321',
        );

        expect(result, true);
        verify(() => mockApiClient.post(
              ApiEndpoints.verifyOtp,
              data: {'email': 'test@example.com', 'otp': '654321'},
            )).called(1);
      });
    });

    group('resetPassword()', () {
      test('calls correct endpoint with email, otp, and new password',
          () async {
        when(() => mockApiClient.post(
              ApiEndpoints.resetPassword,
              data: {
                'email': 'test@example.com',
                'otp': '654321',
                'newPassword': 'newpass123',
              },
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: ApiEndpoints.resetPassword),
            ));

        await repository.resetPassword(
          email: 'test@example.com',
          otp: '654321',
          newPassword: 'newpass123',
        );

        verify(() => mockApiClient.post(
              ApiEndpoints.resetPassword,
              data: {
                'email': 'test@example.com',
                'otp': '654321',
                'newPassword': 'newpass123',
              },
            )).called(1);
      });
    });

    group('logout()', () {
      test('posts refresh token and clears storage', () async {
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => 'stored-refresh-token');
        when(() => mockApiClient.post(
              ApiEndpoints.logout,
              data: {'refreshToken': 'stored-refresh-token'},
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiEndpoints.logout),
            ));
        when(() => mockStorage.clearTokens()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => mockStorage.getRefreshToken()).called(1);
        verify(() => mockApiClient.post(
              ApiEndpoints.logout,
              data: {'refreshToken': 'stored-refresh-token'},
            )).called(1);
        verify(() => mockStorage.clearTokens()).called(1);
      });

      test('clears tokens even when no refresh token', () async {
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => null);
        when(() => mockStorage.clearTokens()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => mockStorage.clearTokens()).called(1);
        verifyNever(() => mockApiClient.post(any(), data: any(named: 'data')));
      });
    });

    group('getCurrentUser()', () {
      test('returns null when no access token', () async {
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => null);

        final user = await repository.getCurrentUser();

        expect(user, isNull);
        verifyNever(() => mockApiClient.get(any()));
      });

      test('returns user when access token exists', () async {
        final profileResponse = {
          'id': 'user-1',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'role': 'USER',
        };

        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => 'valid-token');
        when(() => mockApiClient.get(ApiEndpoints.profile))
            .thenAnswer((_) async => Response(
                  data: profileResponse,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ApiEndpoints.profile),
                ));

        final user = await repository.getCurrentUser();

        expect(user, isNotNull);
        expect(user!.id, 'user-1');
        expect(user.email, 'test@example.com');
      });
    });

    group('changePassword()', () {
      test('calls correct endpoint', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.changePassword,
              data: {
                'currentPassword': 'oldpass',
                'newPassword': 'newpass',
              },
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: ApiEndpoints.changePassword),
            ));

        await repository.changePassword(
          currentPassword: 'oldpass',
          newPassword: 'newpass',
        );

        verify(() => mockApiClient.post(
              ApiEndpoints.changePassword,
              data: {
                'currentPassword': 'oldpass',
                'newPassword': 'newpass',
              },
            )).called(1);
      });
    });
  });
}
