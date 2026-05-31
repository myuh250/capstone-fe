import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/repositories/library_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late RealLibraryRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = RealLibraryRepository(mockApiClient);
  });

  group('LibraryRepository', () {
    group('getReadingHistory()', () {
      test('returns list from array response', () async {
        final historyJson = [
          {
            'id': '1',
            'mangaId': 'manga-1',
            'mangaTitle': 'One Piece',
            'coverUrl': 'https://example.com/cover.jpg',
            'chapterId': 'ch-100',
            'chapterNumber': 100.0,
            'lastReadAt': '2024-06-01T10:00:00.000Z',
          }
        ];

        when(() => mockApiClient.get(ApiEndpoints.historyProgress))
            .thenAnswer((_) async => Response(
                  data: historyJson,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getReadingHistory();

        expect(result.length, 1);
        expect(result.first.mangaTitle, 'One Piece');
      });

      test('returns list from paginated response', () async {
        when(() => mockApiClient.get(ApiEndpoints.historyProgress))
            .thenAnswer((_) async => Response(
                  data: {
                    'content': [
                      {
                        'id': '2',
                        'mangaId': 'manga-2',
                        'mangaTitle': 'Naruto',
                        'coverUrl': '',
                        'chapterId': 'ch-50',
                        'chapterNumber': 50,
                        'lastReadAt': '2024-05-01T00:00:00.000Z',
                      }
                    ]
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getReadingHistory();

        expect(result.length, 1);
        expect(result.first.mangaTitle, 'Naruto');
      });

      test('returns empty list when no data', () async {
        when(() => mockApiClient.get(ApiEndpoints.historyProgress))
            .thenAnswer((_) async => Response(
                  data: [],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getReadingHistory();

        expect(result, isEmpty);
      });
    });

    group('removeFromHistory()', () {
      test('calls delete endpoint', () async {
        when(() => mockApiClient.delete(ApiEndpoints.historyDelete('1')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 204,
                  requestOptions: RequestOptions(path: ''),
                ));

        await repository.removeFromHistory('1');

        verify(() => mockApiClient.delete(ApiEndpoints.historyDelete('1'))).called(1);
      });
    });

    group('saveProgress()', () {
      test('sends progress data', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.historyProgress,
              data: {
                'mangaId': 'manga-1',
                'chapterId': 'ch-5',
                'page': 10,
              },
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        await repository.saveProgress(
          mangaId: 'manga-1',
          mangaTitle: 'Test',
          coverUrl: '',
          chapterId: 'ch-5',
          chapterNumber: 5.0,
          totalChapters: 100,
          chaptersRead: 5,
          lastPageRead: 10,
        );

        verify(() => mockApiClient.post(
              ApiEndpoints.historyProgress,
              data: {
                'mangaId': 'manga-1',
                'chapterId': 'ch-5',
                'page': 10,
              },
            )).called(1);
      });
    });

    group('getFavorites()', () {
      test('returns manga list from library', () async {
        when(() => mockApiClient.get(ApiEndpoints.libraryMeByStatus('FOLLOWING')))
            .thenAnswer((_) async => Response(
                  data: [
                    {
                      'id': 1,
                      'manga': {
                        'id': 'manga-1',
                        'title': 'Favorite Manga',
                        'coverUrl': 'https://example.com/fav.jpg',
                      },
                      'status': 'FOLLOWING',
                    }
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getFavorites();

        expect(result.length, 1);
        expect(result.first.title, 'Favorite Manga');
      });
    });

    group('getMostRecentlyRead()', () {
      test('returns most recent entry', () async {
        when(() => mockApiClient.get(ApiEndpoints.historyProgress))
            .thenAnswer((_) async => Response(
                  data: [
                    {
                      'id': '1',
                      'mangaId': 'manga-1',
                      'mangaTitle': 'Old',
                      'coverUrl': '',
                      'chapterId': 'c1',
                      'chapterNumber': 1,
                      'lastReadAt': '2024-01-01T00:00:00.000Z',
                    },
                    {
                      'id': '2',
                      'mangaId': 'manga-2',
                      'mangaTitle': 'Recent',
                      'coverUrl': '',
                      'chapterId': 'c2',
                      'chapterNumber': 2,
                      'lastReadAt': '2024-06-01T00:00:00.000Z',
                    },
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getMostRecentlyRead();

        expect(result, isNotNull);
        expect(result!.mangaTitle, 'Recent');
      });

      test('returns null when history is empty', () async {
        when(() => mockApiClient.get(ApiEndpoints.historyProgress))
            .thenAnswer((_) async => Response(
                  data: [],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getMostRecentlyRead();

        expect(result, isNull);
      });
    });
  });
}
