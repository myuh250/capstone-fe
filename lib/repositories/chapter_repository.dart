import '../models/chapter.dart';
import '../models/chapter_page.dart';

abstract class ChapterRepository {
  Future<List<ChapterPage>> getPages(String chapterId);
  Future<Chapter?> getPreviousChapter(String mangaId, double chapterNumber);
  Future<Chapter?> getNextChapter(String mangaId, double chapterNumber);
  Future<void> saveReadingProgress(
    String mangaId,
    String chapterId,
    int currentPage,
  );
}

class FakeChapterRepository implements ChapterRepository {
  static const _sampleImageUrls = [
    'https://uploads.mangadex.org/data/39c3a9c2-3ce8-4aa1-97a1-41d7be1d2fe8/x1-5df4543c37f66ff3.jpg',
    'https://uploads.mangadex.org/data/39c3a9c2-3ce8-4aa1-97a1-41d7be1d2fe8/x2-a1fa40b58dc4555f.jpg',
    'https://uploads.mangadex.org/data/39c3a9c2-3ce8-4aa1-97a1-41d7be1d2fe8/x3-0a6d25a5cfb46e53.jpg',
    'https://picsum.photos/800/1200?random=1',
    'https://picsum.photos/800/1200?random=2',
    'https://picsum.photos/800/1200?random=3',
    'https://picsum.photos/800/1200?random=4',
    'https://picsum.photos/800/1200?random=5',
    'https://picsum.photos/800/1200?random=6',
    'https://picsum.photos/800/1200?random=7',
    'https://picsum.photos/800/1200?random=8',
    'https://picsum.photos/800/1200?random=9',
    'https://picsum.photos/800/1200?random=10',
    'https://picsum.photos/800/1200?random=11',
    'https://picsum.photos/800/1200?random=12',
    'https://picsum.photos/800/1200?random=13',
    'https://picsum.photos/800/1200?random=14',
    'https://picsum.photos/800/1200?random=15',
    'https://picsum.photos/800/1200?random=16',
    'https://picsum.photos/800/1200?random=17',
    'https://picsum.photos/800/1200?random=18',
  ];

  @override
  Future<List<ChapterPage>> getPages(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(
      18,
      (i) => ChapterPage(
        id: '${chapterId}_page_${i + 1}',
        chapterId: chapterId,
        pageNumber: i + 1,
        imageUrl: _sampleImageUrls[i % _sampleImageUrls.length],
        width: 800,
        height: 1200,
      ),
    );
  }

  @override
  Future<Chapter?> getPreviousChapter(
    String mangaId,
    double chapterNumber,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (chapterNumber <= 1) return null;
    return Chapter(
      id: '${mangaId}_ch_${(chapterNumber - 1).toInt()}',
      mangaId: mangaId,
      number: chapterNumber - 1,
      pageCount: 18,
    );
  }

  @override
  Future<Chapter?> getNextChapter(
    String mangaId,
    double chapterNumber,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Chapter(
      id: '${mangaId}_ch_${(chapterNumber + 1).toInt()}',
      mangaId: mangaId,
      number: chapterNumber + 1,
      pageCount: 18,
    );
  }

  @override
  Future<void> saveReadingProgress(
    String mangaId,
    String chapterId,
    int currentPage,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
