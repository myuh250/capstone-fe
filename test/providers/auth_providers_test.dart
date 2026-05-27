import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  User _sampleUser() {
    return const User(
      id: 'user-1',
      email: 'test@example.com',
      displayName: 'Test User',
      role: UserRole.user,
      isPremium: false,
    );
  }

  group('AuthNotifier', () {
    test('initializes by loading current user', () async {
      final user = _sampleUser();
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => user);

      final notifier = AuthNotifier(mockRepo);

      await Future.delayed(Duration.zero);

      expect(notifier.state.valueOrNull, user);
      verify(() => mockRepo.getCurrentUser()).called(1);
    });

    test('initializes to null when no current user', () async {
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);

      final notifier = AuthNotifier(mockRepo);

      await Future.delayed(Duration.zero);

      expect(notifier.state.valueOrNull, isNull);
    });

    group('login()', () {
      test('success updates state with user', () async {
        final user = _sampleUser();
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
        when(() => mockRepo.login(
              email: 'test@example.com',
              password: 'password123',
            )).thenAnswer((_) async => user);

        final notifier = AuthNotifier(mockRepo);
        await Future.delayed(Duration.zero);

        await notifier.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(notifier.state.valueOrNull, user);
        expect(notifier.state.hasError, false);
      });

      test('failure sets error state', () async {
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
        when(() => mockRepo.login(
              email: 'test@example.com',
              password: 'wrong',
            )).thenThrow(Exception('Invalid credentials'));

        final notifier = AuthNotifier(mockRepo);
        await Future.delayed(Duration.zero);

        await notifier.login(
          email: 'test@example.com',
          password: 'wrong',
        );

        expect(notifier.state.hasError, true);
      });
    });

    group('logout()', () {
      test('clears state to null', () async {
        final user = _sampleUser();
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => user);
        when(() => mockRepo.logout()).thenAnswer((_) async {});

        final notifier = AuthNotifier(mockRepo);
        await Future.delayed(Duration.zero);

        expect(notifier.state.valueOrNull, user);

        await notifier.logout();

        expect(notifier.state.valueOrNull, isNull);
        verify(() => mockRepo.logout()).called(1);
      });
    });

    group('register()', () {
      test('success updates state with user', () async {
        final user = _sampleUser();
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
        when(() => mockRepo.register(
              email: 'new@example.com',
              password: 'password123',
              displayName: 'New User',
            )).thenAnswer((_) async => user);

        final notifier = AuthNotifier(mockRepo);
        await Future.delayed(Duration.zero);

        await notifier.register(
          email: 'new@example.com',
          password: 'password123',
          displayName: 'New User',
        );

        expect(notifier.state.valueOrNull, user);
        expect(notifier.state.hasError, false);
        verify(() => mockRepo.register(
              email: 'new@example.com',
              password: 'password123',
              displayName: 'New User',
            )).called(1);
      });

      test('failure sets error state', () async {
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
        when(() => mockRepo.register(
              email: 'existing@example.com',
              password: 'password123',
              displayName: 'Existing',
            )).thenThrow(Exception('Email already exists'));

        final notifier = AuthNotifier(mockRepo);
        await Future.delayed(Duration.zero);

        await notifier.register(
          email: 'existing@example.com',
          password: 'password123',
          displayName: 'Existing',
        );

        expect(notifier.state.hasError, true);
      });
    });
  });

}
