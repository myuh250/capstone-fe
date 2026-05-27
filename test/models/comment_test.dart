import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/comment.dart';

void main() {
  group('Comment', () {
    group('fromJson()', () {
      test('parses comment with user and manga nested objects', () {
        final json = {
          'id': '101',
          'user': {
            'id': 'user-1',
            'displayName': 'John Doe',
            'username': 'johndoe',
            'avatarUrl': 'https://example.com/avatar.png',
            'isPremium': true,
          },
          'manga': {
            'id': 'manga-1',
          },
          'content': 'Great chapter!',
          'createdAt': '2024-03-15T10:00:00Z',
          'updatedAt': null,
          'parentId': null,
          'replies': [],
          'edited': false,
        };

        final comment = Comment.fromJson(json);

        expect(comment.id, '101');
        expect(comment.userId, 'user-1');
        expect(comment.userName, 'John Doe');
        expect(comment.userAvatarUrl, 'https://example.com/avatar.png');
        expect(comment.isUserPremium, true);
        expect(comment.mangaId, 'manga-1');
        expect(comment.content, 'Great chapter!');
        expect(comment.parentId, isNull);
        expect(comment.isEdited, false);
      });

      test('falls back to username when displayName missing', () {
        final json = {
          'id': '102',
          'user': {
            'id': 'user-2',
            'username': 'janedoe',
          },
          'manga': {
            'id': 'manga-2',
          },
          'content': 'Nice!',
          'createdAt': '2024-03-15T10:00:00Z',
        };

        final comment = Comment.fromJson(json);

        expect(comment.userName, 'janedoe');
      });

      test('falls back to flat fields when nested objects are null', () {
        final json = {
          'id': '103',
          'mangaId': 'manga-3',
          'userId': 'user-3',
          'userName': 'FlatUser',
          'userAvatarUrl': 'https://example.com/flat-avatar.png',
          'content': 'Flat structure test',
          'createdAt': '2024-04-01T08:30:00Z',
        };

        final comment = Comment.fromJson(json);

        expect(comment.mangaId, 'manga-3');
        expect(comment.userId, 'user-3');
        expect(comment.userName, 'FlatUser');
        expect(comment.userAvatarUrl, 'https://example.com/flat-avatar.png');
      });

      test('parses replies array', () {
        final json = {
          'id': '104',
          'user': {'id': 'user-4', 'displayName': 'Author'},
          'manga': {'id': 'manga-4'},
          'content': 'Parent comment',
          'createdAt': '2024-05-01T12:00:00Z',
          'replies': [
            {
              'id': '105',
              'user': {'id': 'user-5', 'displayName': 'Replier'},
              'manga': {'id': 'manga-4'},
              'content': 'This is a reply',
              'createdAt': '2024-05-01T12:30:00Z',
              'parentId': '104',
            },
            {
              'id': '106',
              'user': {'id': 'user-6', 'displayName': 'Another'},
              'manga': {'id': 'manga-4'},
              'content': 'Second reply',
              'createdAt': '2024-05-01T13:00:00Z',
              'parentId': '104',
            },
          ],
        };

        final comment = Comment.fromJson(json);

        expect(comment.replies.length, 2);
        expect(comment.replies[0].id, '105');
        expect(comment.replies[0].content, 'This is a reply');
        expect(comment.replies[0].parentId, '104');
        expect(comment.replies[1].id, '106');
        expect(comment.replies[1].userName, 'Another');
      });

      test('handles UTC timestamps correctly', () {
        final json = {
          'id': '107',
          'user': {'id': 'user-7', 'displayName': 'Test'},
          'manga': {'id': 'manga-7'},
          'content': 'UTC test',
          'createdAt': '2024-06-15T14:30:00Z',
          'updatedAt': '2024-06-15T15:00:00Z',
        };

        final comment = Comment.fromJson(json);

        expect(comment.createdAt.isUtc, true);
        expect(comment.createdAt.year, 2024);
        expect(comment.createdAt.month, 6);
        expect(comment.createdAt.day, 15);
        expect(comment.createdAt.hour, 14);
        expect(comment.createdAt.minute, 30);
        expect(comment.updatedAt, isNotNull);
        expect(comment.updatedAt!.isUtc, true);
        expect(comment.updatedAt!.hour, 15);
      });

      test('handles non-UTC timestamp by converting to UTC', () {
        final json = {
          'id': '108',
          'user': {'id': 'user-8', 'displayName': 'Test'},
          'manga': {'id': 'manga-8'},
          'content': 'Non-UTC test',
          'createdAt': '2024-06-15T14:30:00',
        };

        final comment = Comment.fromJson(json);

        expect(comment.createdAt.isUtc, true);
        expect(comment.createdAt.hour, 14);
        expect(comment.createdAt.minute, 30);
      });

      test('parses edited field', () {
        final json = {
          'id': '109',
          'user': {'id': 'user-9', 'displayName': 'Editor'},
          'manga': {'id': 'manga-9'},
          'content': 'Edited comment',
          'createdAt': '2024-07-01T10:00:00Z',
          'edited': true,
        };

        final comment = Comment.fromJson(json);

        expect(comment.isEdited, true);
      });

      test('parses isEdited field as fallback', () {
        final json = {
          'id': '110',
          'user': {'id': 'user-10', 'displayName': 'Editor2'},
          'manga': {'id': 'manga-10'},
          'content': 'Another edited comment',
          'createdAt': '2024-07-01T10:00:00Z',
          'isEdited': true,
        };

        final comment = Comment.fromJson(json);

        expect(comment.isEdited, true);
      });
    });

    group('copyWith()', () {
      test('creates copy with updated fields', () {
        final original = Comment(
          id: '1',
          mangaId: 'manga-1',
          userId: 'user-1',
          userName: 'Original User',
          content: 'Original content',
          createdAt: DateTime.utc(2024, 1, 1),
        );

        final copy = original.copyWith(
          content: 'Updated content',
          isEdited: true,
        );

        expect(copy.id, '1');
        expect(copy.mangaId, 'manga-1');
        expect(copy.content, 'Updated content');
        expect(copy.isEdited, true);
        expect(copy.userName, 'Original User');
      });

      test('preserves all fields when no arguments given', () {
        final original = Comment(
          id: '2',
          mangaId: 'manga-2',
          userId: 'user-2',
          userName: 'Test User',
          userAvatarUrl: 'https://example.com/avatar.png',
          isUserPremium: true,
          content: 'Test content',
          createdAt: DateTime.utc(2024, 3, 15),
          updatedAt: DateTime.utc(2024, 3, 16),
          parentId: 'parent-1',
          replies: [],
          isEdited: true,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.mangaId, original.mangaId);
        expect(copy.userId, original.userId);
        expect(copy.userName, original.userName);
        expect(copy.userAvatarUrl, original.userAvatarUrl);
        expect(copy.isUserPremium, original.isUserPremium);
        expect(copy.content, original.content);
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, original.updatedAt);
        expect(copy.parentId, original.parentId);
        expect(copy.replies, original.replies);
        expect(copy.isEdited, original.isEdited);
      });
    });
  });
}
