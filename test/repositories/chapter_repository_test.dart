import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/repositories/chapter_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late RealChapterRepository repository;

  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:9000/api');
  });

  setUp(() {
    mockApiClient = MockApiClient();
    repository = RealChapterRepository(mockApiClient);
  });

  group('ChapterRepository', () {
    group('getPages()', () {
      test('returns pages from list response', () async {
        when(() => mockApiClient.get(ApiEndpoints.chapterImages('ch-1')))
            .thenAnswer((_) async => Response(
                  data: [
                    '/api/proxy/image?chapterId=ch-1&page=0',
                    '/api/proxy/image?chapterId=ch-1&page=1',
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getPages('ch-1');

        expect(result.length, 2);
        expect(result.first.pageNumber, 1);
        expect(result.last.pageNumber, 2);
        expect(result.first.chapterId, 'ch-1');
      });

      test('handles map response with images key', () async {
        when(() => mockApiClient.get(ApiEndpoints.chapterImages('ch-2')))
            .thenAnswer((_) async => Response(
                  data: {
                    'images': ['/api/proxy/image?chapterId=ch-2&page=0']
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getPages('ch-2');

        expect(result.length, 1);
      });

      test('handles absolute URLs without modification', () async {
        when(() => mockApiClient.get(ApiEndpoints.chapterImages('ch-3')))
            .thenAnswer((_) async => Response(
                  data: ['https://cdn.mangadex.org/img/page1.jpg'],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getPages('ch-3');

        expect(result.first.imageUrl, 'https://cdn.mangadex.org/img/page1.jpg');
      });
    });

    group('getPreviousChapter()', () {
      test('returns previous chapter when exists', () async {
        final chapters = [
          {'id': 'ch-1', 'mangaId': 'manga-1', 'chapterNumber': 1.0},
          {'id': 'ch-2', 'mangaId': 'manga-1', 'chapterNumber': 2.0},
          {'id': 'ch-3', 'mangaId': 'manga-1', 'chapterNumber': 3.0},
        ];

        when(() => mockApiClient.get(ApiEndpoints.chaptersByManga('manga-1')))
            .thenAnswer((_) async => Response(
                  data: chapters,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getPreviousChapter('manga-1', 2.0);

        expect(result, isNotNull);
        expect(result!.id, 'ch-1');
        expect(result.number, 1.0);
      });

      test('returns null for first chapter', () async {
        final chapters = [
          {'id': 'ch-1', 'mangaId': 'manga-1', 'chapterNumber': 1.0},
          {'id': 'ch-2', 'mangaId': 'manga-1', 'chapterNumber': 2.0},
        ];

        when(() => mockApiClient.get(ApiEndpoints.chaptersByManga('manga-1')))
            .thenAnswer((_) async => Response(
                  data: chapters,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getPreviousChapter('manga-1', 1.0);

        expect(result, isNull);
      });
    });

    group('getNextChapter()', () {
      test('returns next chapter when exists', () async {
        final chapters = [
          {'id': 'ch-1', 'mangaId': 'manga-1', 'chapterNumber': 1.0},
          {'id': 'ch-2', 'mangaId': 'manga-1', 'chapterNumber': 2.0},
          {'id': 'ch-3', 'mangaId': 'manga-1', 'chapterNumber': 3.0},
        ];

        when(() => mockApiClient.get(ApiEndpoints.chaptersByManga('manga-1')))
            .thenAnswer((_) async => Response(
                  data: chapters,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getNextChapter('manga-1', 2.0);

        expect(result, isNotNull);
        expect(result!.id, 'ch-3');
        expect(result.number, 3.0);
      });

      test('returns null for last chapter', () async {
        final chapters = [
          {'id': 'ch-1', 'mangaId': 'manga-1', 'chapterNumber': 1.0},
          {'id': 'ch-2', 'mangaId': 'manga-1', 'chapterNumber': 2.0},
        ];

        when(() => mockApiClient.get(ApiEndpoints.chaptersByManga('manga-1')))
            .thenAnswer((_) async => Response(
                  data: chapters,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getNextChapter('manga-1', 2.0);

        expect(result, isNull);
      });
    });

    group('saveReadingProgress()', () {
      test('sends correct data', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.historyProgress,
              data: {'mangaId': 'manga-1', 'chapterId': 'ch-5', 'page': 10},
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        await repository.saveReadingProgress('manga-1', 'ch-5', 10);

        verify(() => mockApiClient.post(
              ApiEndpoints.historyProgress,
              data: {'mangaId': 'manga-1', 'chapterId': 'ch-5', 'page': 10},
            )).called(1);
      });
    });
  });
}
