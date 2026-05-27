import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user.dart';

void main() {
  group('User', () {
    group('fromJson()', () {
      test('parses user correctly with all fields', () {
        final json = {
          'id': 'user-1',
          'email': 'john@example.com',
          'displayName': 'John Doe',
          'avatarUrl': 'https://example.com/avatar.png',
          'bio': 'I love manga!',
          'role': 'USER',
          'status': 'active',
          'isPremium': true,
          'createdAt': '2024-01-15T10:00:00Z',
        };

        final user = User.fromJson(json);

        expect(user.id, 'user-1');
        expect(user.email, 'john@example.com');
        expect(user.displayName, 'John Doe');
        expect(user.avatarUrl, 'https://example.com/avatar.png');
        expect(user.bio, 'I love manga!');
        expect(user.role, UserRole.user);
        expect(user.status, UserStatus.active);
        expect(user.isPremium, true);
        expect(user.createdAt, DateTime.parse('2024-01-15T10:00:00Z'));
      });

      test('uses username as fallback for displayName', () {
        final json = {
          'id': 'user-2',
          'email': 'jane@example.com',
          'username': 'janedoe',
          'role': 'USER',
        };

        final user = User.fromJson(json);

        expect(user.displayName, 'janedoe');
      });

      test('parses admin role', () {
        final json = {
          'id': 'user-3',
          'email': 'admin@example.com',
          'displayName': 'Admin User',
          'role': 'ADMIN',
        };

        final user = User.fromJson(json);

        expect(user.role, UserRole.admin);
      });

      test('parses moderator role', () {
        final json = {
          'id': 'user-4',
          'email': 'mod@example.com',
          'displayName': 'Moderator User',
          'role': 'MODERATOR',
        };

        final user = User.fromJson(json);

        expect(user.role, UserRole.moderator);
      });

      test('defaults to user role for unknown role string', () {
        final json = {
          'id': 'user-5',
          'email': 'test@example.com',
          'displayName': 'Unknown Role',
          'role': 'SUPERADMIN',
        };

        final user = User.fromJson(json);

        expect(user.role, UserRole.user);
      });

      test('defaults to user role when role is null', () {
        final json = {
          'id': 'user-6',
          'email': 'test@example.com',
          'displayName': 'No Role',
        };

        final user = User.fromJson(json);

        expect(user.role, UserRole.user);
      });

      test('parses banned status', () {
        final json = {
          'id': 'user-7',
          'email': 'banned@example.com',
          'displayName': 'Banned User',
          'role': 'USER',
          'status': 'banned',
        };

        final user = User.fromJson(json);

        expect(user.status, UserStatus.banned);
      });

      test('parses pending status', () {
        final json = {
          'id': 'user-8',
          'email': 'pending@example.com',
          'displayName': 'Pending User',
          'role': 'USER',
          'status': 'pending',
        };

        final user = User.fromJson(json);

        expect(user.status, UserStatus.pending);
      });

      test('defaults to active status for unknown status', () {
        final json = {
          'id': 'user-9',
          'email': 'test@example.com',
          'displayName': 'Unknown Status',
          'role': 'USER',
          'status': 'suspended',
        };

        final user = User.fromJson(json);

        expect(user.status, UserStatus.active);
      });

      test('handles nullable fields', () {
        final json = {
          'id': 'user-10',
          'email': 'minimal@example.com',
          'displayName': 'Minimal',
          'role': 'USER',
        };

        final user = User.fromJson(json);

        expect(user.avatarUrl, isNull);
        expect(user.bio, isNull);
        expect(user.createdAt, isNull);
      });

      test('converts numeric id to string', () {
        final json = {
          'id': 42,
          'email': 'numeric@example.com',
          'displayName': 'Numeric ID',
          'role': 'USER',
        };

        final user = User.fromJson(json);

        expect(user.id, '42');
      });

      test('isPremium derived from premium role string', () {
        final json = {
          'id': 'user-11',
          'email': 'premium@example.com',
          'displayName': 'Premium User',
          'role': 'premium',
        };

        final user = User.fromJson(json);

        expect(user.isPremium, true);
      });
    });

    group('copyWith()', () {
      test('creates copy with updated fields', () {
        final original = User(
          id: '1',
          email: 'test@example.com',
          displayName: 'Test',
          role: UserRole.user,
          isPremium: false,
        );

        final copy = original.copyWith(
          displayName: 'Updated Name',
          isPremium: true,
        );

        expect(copy.id, '1');
        expect(copy.email, 'test@example.com');
        expect(copy.displayName, 'Updated Name');
        expect(copy.isPremium, true);
      });
    });

    group('toJson()', () {
      test('serializes user correctly', () {
        final user = User(
          id: 'user-1',
          email: 'test@example.com',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          bio: 'Bio text',
          role: UserRole.user,
          status: UserStatus.active,
          isPremium: false,
          createdAt: DateTime.utc(2024, 1, 15, 10, 0, 0),
        );

        final json = user.toJson();

        expect(json['id'], 'user-1');
        expect(json['email'], 'test@example.com');
        expect(json['displayName'], 'Test User');
        expect(json['avatarUrl'], 'https://example.com/avatar.png');
        expect(json['bio'], 'Bio text');
        expect(json['role'], 'user');
        expect(json['status'], 'active');
        expect(json['isPremium'], false);
        expect(json['createdAt'], '2024-01-15T10:00:00.000Z');
      });
    });
  });
}
