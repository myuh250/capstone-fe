import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/reading_history.dart';

void main() {
  group('ReadingHistory', () {
    group('fromJson()', () {
      test('parses full object', () {
        final json = {
          'id': '1',
          'mangaId': 'manga-1',
          'mangaTitle': 'One Piece',
          'coverUrl': 'https://example.com/cover.jpg',
          'lastChapterId': 'ch-100',
          'lastChapterNumber': 100.0,
          'lastReadAt': '2024-06-01T10:00:00.000Z',
          'totalChapters': 1100,
          'chaptersRead': 100,
          'lastPageRead': 15,
        };

        final history = ReadingHistory.fromJson(json);

        expect(history.id, '1');
        expect(history.mangaId, 'manga-1');
        expect(history.mangaTitle, 'One Piece');
        expect(history.coverUrl, 'https://example.com/cover.jpg');
        expect(history.lastChapterId, 'ch-100');
        expect(history.lastChapterNumber, 100.0);
        expect(history.totalChapters, 1100);
        expect(history.chaptersRead, 100);
        expect(history.lastPageRead, 15);
      });

      test('handles alternative field names', () {
        final json = {
          'id': '2',
          'mangaId': 'manga-2',
          'mangaTitle': 'Naruto',
          'mangaCoverUrl': 'https://example.com/naruto.jpg',
          'chapterId': 'ch-50',
          'chapterNumber': 50.0,
          'lastReadTime': '2024-05-15T08:00:00.000Z',
        };

        final history = ReadingHistory.fromJson(json);

        expect(history.coverUrl, 'https://example.com/naruto.jpg');
        expect(history.lastChapterId, 'ch-50');
        expect(history.lastChapterNumber, 50.0);
      });

      test('handles missing optional fields', () {
        final json = {
          'mangaId': 'manga-3',
          'mangaTitle': 'Test',
          'coverUrl': '',
          'lastChapterId': 'ch-1',
          'lastChapterNumber': 1,
          'lastReadAt': '2024-01-01T00:00:00.000Z',
        };

        final history = ReadingHistory.fromJson(json);

        expect(history.id, isNull);
        expect(history.totalChapters, 0);
        expect(history.chaptersRead, 0);
        expect(history.lastPageRead, 0);
      });
    });

    group('progressPercent', () {
      test('calculates correctly', () {
        final history = ReadingHistory(
          mangaId: 'm1', mangaTitle: 'T', coverUrl: '', lastChapterId: 'c1',
          lastChapterNumber: 1, lastReadAt: DateTime.now(),
          totalChapters: 100, chaptersRead: 50,
        );
        expect(history.progressPercent, 0.5);
      });

      test('returns 0 when totalChapters is 0', () {
        final history = ReadingHistory(
          mangaId: 'm1', mangaTitle: 'T', coverUrl: '', lastChapterId: 'c1',
          lastChapterNumber: 1, lastReadAt: DateTime.now(),
          totalChapters: 0, chaptersRead: 0,
        );
        expect(history.progressPercent, 0.0);
      });

      test('clamps to 1.0 maximum', () {
        final history = ReadingHistory(
          mangaId: 'm1', mangaTitle: 'T', coverUrl: '', lastChapterId: 'c1',
          lastChapterNumber: 1, lastReadAt: DateTime.now(),
          totalChapters: 10, chaptersRead: 15,
        );
        expect(history.progressPercent, 1.0);
      });
    });

    group('copyWith()', () {
      test('copies with new values', () {
        final original = ReadingHistory(
          mangaId: 'm1', mangaTitle: 'T', coverUrl: '', lastChapterId: 'c1',
          lastChapterNumber: 1, lastReadAt: DateTime(2024, 1, 1),
          chaptersRead: 5,
        );
        final copy = original.copyWith(chaptersRead: 10, lastChapterNumber: 2.0);

        expect(copy.chaptersRead, 10);
        expect(copy.lastChapterNumber, 2.0);
        expect(copy.mangaId, 'm1');
      });
    });
  });
}
