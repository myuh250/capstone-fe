import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/manga.dart';

void main() {
  group('Manga', () {
    group('fromJson()', () {
      test('parses full manga object', () {
        final json = {
          'id': 'manga-1',
          'title': 'One Piece',
          'slug': 'one-piece',
          'description': 'A pirate adventure manga',
          'coverUrl': 'https://example.com/cover.jpg',
          'tags': ['Action', 'Adventure', 'Comedy'],
          'status': 'ONGOING',
          'averageRating': 4.8,
          'totalChapters': 1100,
          'author': 'Oda Eiichiro',
          'updatedAt': '2024-06-01T00:00:00.000Z',
          'hasEarlyAccess': true,
        };

        final manga = Manga.fromJson(json);

        expect(manga.id, 'manga-1');
        expect(manga.title, 'One Piece');
        expect(manga.slug, 'one-piece');
        expect(manga.description, 'A pirate adventure manga');
        expect(manga.coverUrl, 'https://example.com/cover.jpg');
        expect(manga.tags, ['Action', 'Adventure', 'Comedy']);
        expect(manga.status, MangaStatus.ongoing);
        expect(manga.averageRating, 4.8);
        expect(manga.totalChapters, 1100);
        expect(manga.author, 'Oda Eiichiro');
        expect(manga.updatedAt, DateTime.parse('2024-06-01T00:00:00.000Z'));
        expect(manga.hasEarlyAccess, true);
      });

      test('handles nullable description', () {
        final json = {
          'id': 'manga-2',
          'title': 'Minimal Manga',
          'coverUrl': 'https://example.com/cover2.jpg',
          'description': null,
        };

        final manga = Manga.fromJson(json);

        expect(manga.description, isNull);
      });

      test('handles nullable slug', () {
        final json = {
          'id': 'manga-3',
          'title': 'No Slug Manga',
          'coverUrl': 'https://example.com/cover3.jpg',
          'slug': null,
        };

        final manga = Manga.fromJson(json);

        expect(manga.slug, isNull);
      });

      test('handles nullable coverUrl field gracefully with required value', () {
        final json = {
          'id': 'manga-4',
          'title': 'Manga With Cover',
          'coverUrl': 'https://example.com/default.jpg',
        };

        final manga = Manga.fromJson(json);

        expect(manga.coverUrl, 'https://example.com/default.jpg');
      });

      test('defaults to ongoing status when status is null', () {
        final json = {
          'id': 'manga-5',
          'title': 'Status Test',
          'coverUrl': 'https://example.com/cover5.jpg',
          'status': null,
        };

        final manga = Manga.fromJson(json);

        expect(manga.status, MangaStatus.ongoing);
      });

      test('parses COMPLETED status', () {
        final json = {
          'id': 'manga-6',
          'title': 'Completed Manga',
          'coverUrl': 'https://example.com/cover6.jpg',
          'status': 'COMPLETED',
        };

        final manga = Manga.fromJson(json);

        expect(manga.status, MangaStatus.completed);
      });

      test('parses HIATUS status', () {
        final json = {
          'id': 'manga-7',
          'title': 'Hiatus Manga',
          'coverUrl': 'https://example.com/cover7.jpg',
          'status': 'HIATUS',
        };

        final manga = Manga.fromJson(json);

        expect(manga.status, MangaStatus.hiatus);
      });

      test('parses CANCELLED status', () {
        final json = {
          'id': 'manga-8',
          'title': 'Cancelled Manga',
          'coverUrl': 'https://example.com/cover8.jpg',
          'status': 'CANCELLED',
        };

        final manga = Manga.fromJson(json);

        expect(manga.status, MangaStatus.cancelled);
      });

      test('defaults averageRating to 0.0 when missing', () {
        final json = {
          'id': 'manga-9',
          'title': 'No Rating',
          'coverUrl': 'https://example.com/cover9.jpg',
        };

        final manga = Manga.fromJson(json);

        expect(manga.averageRating, 0.0);
      });

      test('defaults totalChapters to 0 when missing', () {
        final json = {
          'id': 'manga-10',
          'title': 'No Chapters',
          'coverUrl': 'https://example.com/cover10.jpg',
        };

        final manga = Manga.fromJson(json);

        expect(manga.totalChapters, 0);
      });

      test('defaults tags to empty list when missing', () {
        final json = {
          'id': 'manga-11',
          'title': 'No Tags',
          'coverUrl': 'https://example.com/cover11.jpg',
        };

        final manga = Manga.fromJson(json);

        expect(manga.tags, isEmpty);
      });

      test('defaults hasEarlyAccess to false when missing', () {
        final json = {
          'id': 'manga-12',
          'title': 'No Early Access',
          'coverUrl': 'https://example.com/cover12.jpg',
        };

        final manga = Manga.fromJson(json);

        expect(manga.hasEarlyAccess, false);
      });

      test('handles nullable author', () {
        final json = {
          'id': 'manga-13',
          'title': 'Unknown Author',
          'coverUrl': 'https://example.com/cover13.jpg',
          'author': null,
        };

        final manga = Manga.fromJson(json);

        expect(manga.author, isNull);
      });
    });
  });
}
