import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/repositories/comment_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late RealCommentRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = RealCommentRepository(mockApiClient);
  });

  group('CommentRepository', () {
    group('getComments()', () {
      test('returns list of comments from list response', () async {
        const mangaId = 'manga-1';
        final responseData = [
          {
            'id': '1',
            'user': {'id': 'user-1', 'displayName': 'Alice'},
            'manga': {'id': mangaId},
            'content': 'Great manga!',
            'createdAt': '2024-03-15T10:00:00Z',
          },
          {
            'id': '2',
            'user': {'id': 'user-2', 'displayName': 'Bob'},
            'manga': {'id': mangaId},
            'content': 'Loved it!',
            'createdAt': '2024-03-16T12:00:00Z',
          },
        ];

        when(() => mockApiClient.get(
              ApiEndpoints.commentsByManga(mangaId),
              queryParameters: {'page': 0},
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.commentsByManga(mangaId)),
            ));

        final comments = await repository.getComments(mangaId);

        expect(comments.length, 2);
        expect(comments[0].id, '1');
        expect(comments[0].userName, 'Alice');
        expect(comments[1].id, '2');
        expect(comments[1].content, 'Loved it!');
      });

      test('returns list from paginated response', () async {
        const mangaId = 'manga-2';
        final responseData = {
          'content': [
            {
              'id': '3',
              'user': {'id': 'user-3', 'displayName': 'Charlie'},
              'manga': {'id': mangaId},
              'content': 'Paginated comment',
              'createdAt': '2024-04-01T08:00:00Z',
            },
          ],
          'totalPages': 1,
        };

        when(() => mockApiClient.get(
              ApiEndpoints.commentsByManga(mangaId),
              queryParameters: {'page': 0},
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.commentsByManga(mangaId)),
            ));

        final comments = await repository.getComments(mangaId);

        expect(comments.length, 1);
        expect(comments[0].content, 'Paginated comment');
      });

      test('passes page parameter', () async {
        const mangaId = 'manga-3';

        when(() => mockApiClient.get(
              ApiEndpoints.commentsByManga(mangaId),
              queryParameters: {'page': 2},
            )).thenAnswer((_) async => Response(
              data: <dynamic>[],
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.commentsByManga(mangaId)),
            ));

        final comments = await repository.getComments(mangaId, page: 2);

        expect(comments, isEmpty);
        verify(() => mockApiClient.get(
              ApiEndpoints.commentsByManga(mangaId),
              queryParameters: {'page': 2},
            )).called(1);
      });
    });

    group('addComment()', () {
      test('posts correctly without parentId', () async {
        const mangaId = 'manga-1';
        const content = 'My new comment';
        final responseData = {
          'id': '10',
          'user': {'id': 'user-1', 'displayName': 'Me'},
          'manga': {'id': mangaId},
          'content': content,
          'createdAt': '2024-05-01T14:00:00Z',
        };

        when(() => mockApiClient.post(
              ApiEndpoints.commentsCreate,
              data: {
                'mangaId': mangaId,
                'content': content,
              },
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 201,
              requestOptions:
                  RequestOptions(path: ApiEndpoints.commentsCreate),
            ));

        final comment = await repository.addComment(mangaId, content);

        expect(comment.id, '10');
        expect(comment.content, content);
        expect(comment.mangaId, mangaId);
        verify(() => mockApiClient.post(
              ApiEndpoints.commentsCreate,
              data: {
                'mangaId': mangaId,
                'content': content,
              },
            )).called(1);
      });

      test('posts with parentId when provided', () async {
        const mangaId = 'manga-1';
        const content = 'My reply';
        const parentId = 'comment-5';
        final responseData = {
          'id': '11',
          'user': {'id': 'user-1', 'displayName': 'Me'},
          'manga': {'id': mangaId},
          'content': content,
          'createdAt': '2024-05-01T15:00:00Z',
          'parentId': parentId,
        };

        when(() => mockApiClient.post(
              ApiEndpoints.commentsCreate,
              data: {
                'mangaId': mangaId,
                'content': content,
                'parentId': parentId,
              },
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 201,
              requestOptions:
                  RequestOptions(path: ApiEndpoints.commentsCreate),
            ));

        final comment =
            await repository.addComment(mangaId, content, parentId: parentId);

        expect(comment.id, '11');
        expect(comment.parentId, parentId);
        verify(() => mockApiClient.post(
              ApiEndpoints.commentsCreate,
              data: {
                'mangaId': mangaId,
                'content': content,
                'parentId': parentId,
              },
            )).called(1);
      });
    });

    group('deleteComment()', () {
      test('calls DELETE on correct endpoint', () async {
        const commentId = 'comment-42';

        when(() => mockApiClient.delete(
              ApiEndpoints.commentDelete(commentId),
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.commentDelete(commentId)),
            ));

        await repository.deleteComment(commentId);

        verify(() => mockApiClient.delete(
              ApiEndpoints.commentDelete(commentId),
            )).called(1);
      });

      test('calls endpoint /comments/{id}', () async {
        const commentId = 'abc-123';
        final expectedPath = '/comments/$commentId';

        when(() => mockApiClient.delete(expectedPath)).thenAnswer(
            (_) async => Response(
                  data: null,
                  statusCode: 204,
                  requestOptions: RequestOptions(path: expectedPath),
                ));

        await repository.deleteComment(commentId);

        verify(() => mockApiClient.delete(expectedPath)).called(1);
      });
    });

    group('editComment()', () {
      test('calls PUT with content data', () async {
        const commentId = 'comment-1';
        const newContent = 'Updated content';

        when(() => mockApiClient.put(
              ApiEndpoints.commentUpdate(commentId),
              data: {'content': newContent},
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(
                  path: ApiEndpoints.commentUpdate(commentId)),
            ));

        await repository.editComment(commentId, newContent);

        verify(() => mockApiClient.put(
              ApiEndpoints.commentUpdate(commentId),
              data: {'content': newContent},
            )).called(1);
      });
    });
  });
}
