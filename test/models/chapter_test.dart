import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/chapter.dart';

void main() {
  group('Chapter', () {
    group('fromJson()', () {
      test('parses full chapter object', () {
        final json = {
          'id': 'ch-1',
          'mangaId': 'manga-1',
          'chapterNumber': 5.0,
          'title': 'The Adventure Begins',
          'pageCount': 20,
          'isRead': true,
          'earlyAccess': true,
          'updatedAt': '2024-06-01T10:00:00.000Z',
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.id, 'ch-1');
        expect(chapter.mangaId, 'manga-1');
        expect(chapter.number, 5.0);
        expect(chapter.title, 'The Adventure Begins');
        expect(chapter.pageCount, 20);
        expect(chapter.isRead, true);
        expect(chapter.isEarlyAccess, true);
        expect(chapter.publishedAt, isNotNull);
      });

      test('handles missing optional fields with defaults', () {
        final json = {
          'id': 'ch-2',
          'mangaId': 'manga-1',
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.number, 0.0);
        expect(chapter.title, isNull);
        expect(chapter.pageCount, 0);
        expect(chapter.isRead, false);
        expect(chapter.isEarlyAccess, false);
        expect(chapter.publishedAt, isNull);
      });

      test('parses number from "number" field as fallback', () {
        final json = {
          'id': 'ch-3',
          'mangaId': 'manga-1',
          'number': 3.5,
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.number, 3.5);
      });

      test('parses isEarlyAccess from "isEarlyAccess" fallback', () {
        final json = {
          'id': 'ch-4',
          'mangaId': 'manga-1',
          'isEarlyAccess': true,
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.isEarlyAccess, true);
      });

      test('parses LocalDateTime array format', () {
        final json = {
          'id': 'ch-5',
          'mangaId': 'manga-1',
          'updatedAt': [2024, 6, 15, 10, 30, 0, 0],
        };

        final chapter = Chapter.fromJson(json);

        expect(chapter.publishedAt, isNotNull);
        expect(chapter.publishedAt!.year, 2024);
        expect(chapter.publishedAt!.month, 6);
        expect(chapter.publishedAt!.day, 15);
      });
    });

    group('displayNumber', () {
      test('shows integer for whole numbers', () {
        final chapter = Chapter(id: 'c1', mangaId: 'm1', number: 10.0);
        expect(chapter.displayNumber, 'Ch.10');
      });

      test('shows decimal for fractional numbers', () {
        final chapter = Chapter(id: 'c1', mangaId: 'm1', number: 10.5);
        expect(chapter.displayNumber, 'Ch.10.5');
      });
    });

    group('copyWith()', () {
      test('copies with new values', () {
        final original = Chapter(id: 'c1', mangaId: 'm1', number: 1.0, isRead: false);
        final copy = original.copyWith(isRead: true, number: 2.0);

        expect(copy.id, 'c1');
        expect(copy.isRead, true);
        expect(copy.number, 2.0);
      });
    });

    group('toJson()', () {
      test('serializes correctly', () {
        final chapter = Chapter(id: 'c1', mangaId: 'm1', number: 5.0, title: 'Test');
        final json = chapter.toJson();

        expect(json['id'], 'c1');
        expect(json['mangaId'], 'm1');
        expect(json['number'], 5.0);
        expect(json['title'], 'Test');
      });
    });
  });
}
