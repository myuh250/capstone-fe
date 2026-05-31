import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/models/manga.dart';
import 'package:frontend/repositories/manga_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late RealMangaRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = RealMangaRepository(mockApiClient);
  });

  final sampleMangaJson = {
    'id': 'manga-1',
    'title': 'One Piece',
    'slug': 'one-piece',
    'coverUrl': 'https://example.com/cover.jpg',
    'status': 'ONGOING',
  };

  group('MangaRepository', () {
    group('fetchFeatured()', () {
      test('returns list of manga', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.mangasTrending,
              queryParameters: {'size': 5},
            )).thenAnswer((_) async => Response(
              data: [sampleMangaJson],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.fetchFeatured();

        expect(result.length, 1);
        expect(result.first.title, 'One Piece');
      });
    });

    group('fetchLatest()', () {
      test('passes page and size params', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.mangasRecent,
              queryParameters: {'page': 0, 'size': 20},
            )).thenAnswer((_) async => Response(
              data: [sampleMangaJson],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.fetchLatest();

        expect(result.length, 1);
      });
    });

    group('fetchCompleted()', () {
      test('passes completed status filter', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.mangas,
              queryParameters: {'status': 'completed', 'page': 0, 'size': 20},
            )).thenAnswer((_) async => Response(
              data: {'content': [sampleMangaJson]},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.fetchCompleted();

        expect(result.length, 1);
      });
    });

    group('getById()', () {
      test('returns single manga', () async {
        when(() => mockApiClient.get(ApiEndpoints.mangaById('manga-1')))
            .thenAnswer((_) async => Response(
                  data: {'data': sampleMangaJson},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getById('manga-1');

        expect(result.id, 'manga-1');
        expect(result.title, 'One Piece');
      });
    });

    group('getBySlug()', () {
      test('returns manga by slug', () async {
        when(() => mockApiClient.get(ApiEndpoints.mangaBySlug('one-piece')))
            .thenAnswer((_) async => Response(
                  data: {'data': sampleMangaJson},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getBySlug('one-piece');

        expect(result.slug, 'one-piece');
      });
    });

    group('search()', () {
      test('sends query params correctly', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.search,
              queryParameters: {
                'page': 0,
                'size': 20,
                'query': 'naruto',
                'genres': ['Action'],
                'status': 'ongoing',
              },
            )).thenAnswer((_) async => Response(
              data: [sampleMangaJson],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.search(
          'naruto',
          genres: ['Action'],
          status: MangaStatus.ongoing,
        );

        expect(result, isNotEmpty);
      });

      test('empty query does not include query param', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.search,
              queryParameters: {'page': 0, 'size': 20},
            )).thenAnswer((_) async => Response(
              data: [],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.search('');

        expect(result, isEmpty);
      });
    });

    group('getChapters()', () {
      test('returns list of chapters', () async {
        final chapterJson = {
          'id': 'ch-1',
          'mangaId': 'manga-1',
          'chapterNumber': 1.0,
          'title': 'Chapter 1',
        };

        when(() => mockApiClient.get(ApiEndpoints.chaptersByManga('manga-1')))
            .thenAnswer((_) async => Response(
                  data: [chapterJson],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getChapters('manga-1');

        expect(result.length, 1);
        expect(result.first.id, 'ch-1');
      });

      test('ascending reverses the list', () async {
        final chapters = [
          {'id': 'ch-2', 'mangaId': 'manga-1', 'chapterNumber': 2.0},
          {'id': 'ch-1', 'mangaId': 'manga-1', 'chapterNumber': 1.0},
        ];

        when(() => mockApiClient.get(ApiEndpoints.chaptersByManga('manga-1')))
            .thenAnswer((_) async => Response(
                  data: chapters,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getChapters('manga-1', ascending: true);

        expect(result.first.id, 'ch-1');
        expect(result.last.id, 'ch-2');
      });
    });

    group('searchPaginated()', () {
      test('returns paginated result', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.search,
              queryParameters: {'page': 0, 'size': 24, 'query': 'test'},
            )).thenAnswer((_) async => Response(
              data: {
                'data': [sampleMangaJson],
                'totalPages': 3,
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.searchPaginated('test');

        expect(result.items.length, 1);
        expect(result.totalPages, 3);
      });
    });

    group('isFavorite()', () {
      test('returns true when manga in library', () async {
        when(() => mockApiClient.get(ApiEndpoints.libraryMe))
            .thenAnswer((_) async => Response(
                  data: [
                    {'id': 1, 'manga': {'id': 'manga-1'}, 'status': 'FOLLOWING'}
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.isFavorite('manga-1');

        expect(result, true);
      });

      test('returns false when manga not in library', () async {
        when(() => mockApiClient.get(ApiEndpoints.libraryMe))
            .thenAnswer((_) async => Response(
                  data: [],
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.isFavorite('manga-1');

        expect(result, false);
      });

      test('returns false on error', () async {
        when(() => mockApiClient.get(ApiEndpoints.libraryMe))
            .thenThrow(Exception('Network error'));

        final result = await repository.isFavorite('manga-1');

        expect(result, false);
      });
    });
  });
}
