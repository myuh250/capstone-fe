import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/comment_providers.dart';
import 'package:frontend/repositories/comment_repository.dart';

class MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  late MockCommentRepository mockRepo;
  const testMangaId = 'manga-123';

  setUp(() {
    mockRepo = MockCommentRepository();
  });

  List<Comment> _sampleComments() {
    return [
      Comment(
        id: '1',
        mangaId: testMangaId,
        userId: 'user-1',
        userName: 'Alice',
        content: 'First comment',
        createdAt: DateTime.utc(2024, 1, 1),
      ),
      Comment(
        id: '2',
        mangaId: testMangaId,
        userId: 'user-2',
        userName: 'Bob',
        content: 'Second comment',
        createdAt: DateTime.utc(2024, 1, 2),
      ),
    ];
  }

  group('CommentsNotifier', () {
    test('loads comments for manga on init', () async {
      final comments = _sampleComments();
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => comments);

      final notifier = CommentsNotifier(mockRepo, testMangaId);

      // Wait for async _load to complete
      await Future.delayed(Duration.zero);

      expect(notifier.state.comments, comments);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      verify(() => mockRepo.getComments(testMangaId)).called(1);
    });

    test('handles load error', () async {
      when(() => mockRepo.getComments(testMangaId))
          .thenThrow(Exception('Network error'));

      final notifier = CommentsNotifier(mockRepo, testMangaId);

      await Future.delayed(Duration.zero);

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNotNull);
    });

    test('addComment() adds to list', () async {
      final comments = _sampleComments();
      final newComment = Comment(
        id: '3',
        mangaId: testMangaId,
        userId: 'user-1',
        userName: 'Alice',
        content: 'New comment',
        createdAt: DateTime.utc(2024, 1, 3),
      );

      // First load returns initial comments
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => comments);
      when(() => mockRepo.addComment(testMangaId, 'New comment'))
          .thenAnswer((_) async => newComment);

      final notifier = CommentsNotifier(mockRepo, testMangaId);
      await Future.delayed(Duration.zero);

      // After addComment, _load is called again - return updated list
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => [...comments, newComment]);

      final result = await notifier.addComment('New comment');

      expect(result, true);
      expect(notifier.state.comments.length, 3);
      expect(notifier.state.isSubmitting, false);
      verify(() => mockRepo.addComment(testMangaId, 'New comment')).called(1);
    });

    test('addComment() returns false on error', () async {
      final comments = _sampleComments();
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => comments);
      when(() => mockRepo.addComment(testMangaId, 'Bad comment'))
          .thenThrow(Exception('Server error'));

      final notifier = CommentsNotifier(mockRepo, testMangaId);
      await Future.delayed(Duration.zero);

      final result = await notifier.addComment('Bad comment');

      expect(result, false);
      expect(notifier.state.isSubmitting, false);
      expect(notifier.state.error, isNotNull);
    });

    test('replyToComment() adds reply', () async {
      final comments = _sampleComments();
      final reply = Comment(
        id: '4',
        mangaId: testMangaId,
        userId: 'user-2',
        userName: 'Bob',
        content: 'Reply to first',
        createdAt: DateTime.utc(2024, 1, 4),
        parentId: '1',
      );

      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => comments);
      when(() => mockRepo.addComment(testMangaId, 'Reply to first',
              parentId: '1'))
          .thenAnswer((_) async => reply);

      final notifier = CommentsNotifier(mockRepo, testMangaId);
      await Future.delayed(Duration.zero);

      // After reply, _load is called again - return updated list
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => [...comments, reply]);

      final result = await notifier.replyToComment('1', 'Reply to first');

      expect(result, true);
      expect(notifier.state.isSubmitting, false);
      verify(() => mockRepo.addComment(testMangaId, 'Reply to first',
          parentId: '1')).called(1);
    });

    test('deleteComment() removes from list', () async {
      final comments = _sampleComments();
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => comments);
      when(() => mockRepo.deleteComment('1')).thenAnswer((_) async {});

      final notifier = CommentsNotifier(mockRepo, testMangaId);
      await Future.delayed(Duration.zero);

      // After delete, _load is called again - return list without deleted comment
      when(() => mockRepo.getComments(testMangaId)).thenAnswer(
          (_) async => comments.where((c) => c.id != '1').toList());

      await notifier.deleteComment('1');

      expect(notifier.state.comments.length, 1);
      expect(notifier.state.comments.first.id, '2');
      verify(() => mockRepo.deleteComment('1')).called(1);
    });

    test('refresh() reloads comments', () async {
      final comments = _sampleComments();
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => comments);

      final notifier = CommentsNotifier(mockRepo, testMangaId);
      await Future.delayed(Duration.zero);

      final refreshedComments = [
        ...comments,
        Comment(
          id: '5',
          mangaId: testMangaId,
          userId: 'user-3',
          userName: 'Charlie',
          content: 'New after refresh',
          createdAt: DateTime.utc(2024, 2, 1),
        ),
      ];
      when(() => mockRepo.getComments(testMangaId))
          .thenAnswer((_) async => refreshedComments);

      await notifier.refresh();

      expect(notifier.state.comments.length, 3);
    });
  });

  group('CommentsState', () {
    test('copyWith() creates new state with updated fields', () {
      const original = CommentsState(
        comments: [],
        isLoading: true,
        isSubmitting: false,
      );

      final updated = original.copyWith(isLoading: false);

      expect(updated.isLoading, false);
      expect(updated.isSubmitting, false);
      expect(updated.comments, isEmpty);
    });

    test('copyWith() preserves fields not specified', () {
      final comments = _sampleComments();
      final original = CommentsState(
        comments: comments,
        isLoading: false,
        isSubmitting: true,
        error: 'Some error',
      );

      final updated = original.copyWith(isSubmitting: false);

      expect(updated.comments, comments);
      expect(updated.isLoading, false);
      expect(updated.isSubmitting, false);
      // error is cleared because copyWith sets error to null when not passed
      // (based on the implementation: error: error parameter without ?? this.error)
    });
  });
}
