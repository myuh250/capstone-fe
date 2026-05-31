import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/repositories/offline_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late OfflineRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = OfflineRepository(mockApiClient);
  });

  group('OfflineRepository', () {
    group('getManifest()', () {
      test('returns chapter manifest', () async {
        when(() => mockApiClient.get(ApiEndpoints.offlineManifest('ch-1')))
            .thenAnswer((_) async => Response(
                  data: {
                    'chapterId': 'ch-1',
                    'mangaId': 'manga-1',
                    'mangaTitle': 'One Piece',
                    'chapterNumber': 5.0,
                    'chapterTitle': 'Chapter 5',
                    'totalPages': 20,
                    'imageUrls': ['img1.jpg', 'img2.jpg'],
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getManifest('ch-1');

        expect(result.chapterId, 'ch-1');
        expect(result.mangaId, 'manga-1');
        expect(result.mangaTitle, 'One Piece');
        expect(result.chapterNumber, 5.0);
        expect(result.totalPages, 20);
        expect(result.imageUrls.length, 2);
      });
    });

    group('markDownloaded()', () {
      test('returns downloaded chapter info', () async {
        when(() => mockApiClient.post(ApiEndpoints.offlineMarkDownloaded('ch-1')))
            .thenAnswer((_) async => Response(
                  data: {
                    'id': 1,
                    'chapterId': 'ch-1',
                    'chapterNumber': 5.0,
                    'chapterTitle': 'Chapter 5',
                    'mangaId': 'manga-1',
                    'mangaTitle': 'One Piece',
                    'downloadedAt': '2024-06-01T10:00:00.000Z',
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.markDownloaded('ch-1');

        expect(result.id, 1);
        expect(result.chapterId, 'ch-1');
        expect(result.mangaTitle, 'One Piece');
        expect(result.downloadedAt, isNotNull);
      });
    });

    group('getMyDownloads()', () {
      test('returns list of downloaded chapters', () async {
        when(() => mockApiClient.get(ApiEndpoints.offlineMyDownloads))
            .thenAnswer((_) async => Response(
                  data: [
                    {
                      'id': 1,
                      'chapterId': 'ch-1',
                      'mangaId': 'manga-1',
                      'mangaTitle': 'One Piece',
                      'chapterNumber': 5.0,
                    },
                    {
                      'id': 2,
                      'chapterId': 'ch-2',
                      'mangaId': 'manga-1',
                      'mangaTitle': 'One Piece',
                      'chapterNumber': 6.0,
                    },
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getMyDownloads();

        expect(result.length, 2);
        expect(result.first.chapterId, 'ch-1');
        expect(result.last.chapterNumber, 6.0);
      });

      test('returns empty list', () async {
        when(() => mockApiClient.get(ApiEndpoints.offlineMyDownloads))
            .thenAnswer((_) async => Response(
                  data: [],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getMyDownloads();

        expect(result, isEmpty);
      });
    });

    group('removeDownload()', () {
      test('calls delete endpoint', () async {
        when(() => mockApiClient.delete(ApiEndpoints.offlineRemove('ch-1')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 204,
                  requestOptions: RequestOptions(path: ''),
                ));

        await repository.removeDownload('ch-1');

        verify(() => mockApiClient.delete(ApiEndpoints.offlineRemove('ch-1'))).called(1);
      });
    });
  });

  group('ChapterManifest', () {
    test('fromJson handles missing optional fields', () {
      final json = {
        'chapterId': 'ch-x',
        'mangaId': 'manga-x',
        'mangaTitle': 'Test',
        'totalPages': 0,
      };

      final manifest = ChapterManifest.fromJson(json);

      expect(manifest.chapterNumber, isNull);
      expect(manifest.chapterTitle, isNull);
      expect(manifest.imageUrls, isEmpty);
    });
  });

  group('DownloadedChapter', () {
    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 1,
        'chapterId': 'ch-x',
        'mangaId': 'manga-x',
        'mangaTitle': 'Test',
      };

      final downloaded = DownloadedChapter.fromJson(json);

      expect(downloaded.chapterNumber, isNull);
      expect(downloaded.chapterTitle, isNull);
      expect(downloaded.mangaCoverUrl, isNull);
      expect(downloaded.downloadedAt, isNull);
    });
  });
}
