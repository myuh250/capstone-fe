import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/network/api_endpoints.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:9000/api');
  });

  group('ApiEndpoints', () {
    test('baseUrl returns configured value', () {
      expect(ApiEndpoints.baseUrl, 'http://localhost:9000/api');
    });

    test('mangaById generates correct path', () {
      expect(ApiEndpoints.mangaById('abc-123'), contains('abc-123'));
    });

    test('mangaBySlug generates correct path', () {
      expect(ApiEndpoints.mangaBySlug('one-piece'), contains('one-piece'));
    });

    test('chaptersByManga generates correct path', () {
      expect(ApiEndpoints.chaptersByManga('manga-1'), contains('manga-1'));
    });

    test('chapterImages generates correct path', () {
      expect(ApiEndpoints.chapterImages('ch-1'), contains('ch-1'));
    });

    test('static endpoints are strings', () {
      expect(ApiEndpoints.login, isA<String>());
      expect(ApiEndpoints.register, isA<String>());
      expect(ApiEndpoints.logout, isA<String>());
      expect(ApiEndpoints.profile, isA<String>());
      expect(ApiEndpoints.mangas, isA<String>());
      expect(ApiEndpoints.mangasTrending, isA<String>());
      expect(ApiEndpoints.mangasRecent, isA<String>());
      expect(ApiEndpoints.search, isA<String>());
      expect(ApiEndpoints.historyProgress, isA<String>());
      expect(ApiEndpoints.libraryMe, isA<String>());
    });
  });
}
