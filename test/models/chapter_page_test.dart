import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/chapter_page.dart';

void main() {
  group('ChapterPage', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'page-1',
        'chapterId': 'ch-1',
        'pageNumber': 5,
        'imageUrl': 'https://example.com/page5.jpg',
        'width': 800,
        'height': 1200,
      };

      final page = ChapterPage.fromJson(json);

      expect(page.id, 'page-1');
      expect(page.chapterId, 'ch-1');
      expect(page.pageNumber, 5);
      expect(page.imageUrl, 'https://example.com/page5.jpg');
      expect(page.width, 800);
      expect(page.height, 1200);
    });

    test('fromJson handles nullable width/height', () {
      final json = {
        'id': 'page-2',
        'chapterId': 'ch-1',
        'pageNumber': 1,
        'imageUrl': 'https://example.com/page1.jpg',
      };

      final page = ChapterPage.fromJson(json);

      expect(page.width, isNull);
      expect(page.height, isNull);
    });
  });
}
