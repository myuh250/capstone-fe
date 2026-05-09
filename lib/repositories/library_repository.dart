import '../models/manga.dart';
import '../models/reading_history.dart';

abstract class LibraryRepository {
  Future<List<ReadingHistory>> getReadingHistory();
  Future<void> removeFromHistory(String mangaId);
  Future<void> saveProgress({
    required String mangaId,
    required String mangaTitle,
    required String coverUrl,
    required String chapterId,
    required double chapterNumber,
    required int totalChapters,
    required int chaptersRead,
    int lastPageRead = 0,
  });
  Future<List<Manga>> getFavorites();
  Future<ReadingHistory?> getMostRecentlyRead();
}

class FakeLibraryRepository implements LibraryRepository {
  final List<ReadingHistory> _history = [
    ReadingHistory(
      mangaId: '1',
      mangaTitle: 'One Piece',
      coverUrl:
          'https://uploads.mangadex.org/covers/a1c7c817-4e59-43b7-9365-09675a149a6f/1a5a20b4-05d9-4b77-9f85-7be7f21dc490.jpg',
      lastChapterId: '1_ch_1088',
      lastChapterNumber: 1088,
      lastReadAt: DateTime.now().subtract(const Duration(hours: 2)),
      totalChapters: 1100,
      chaptersRead: 1088,
      lastPageRead: 12,
    ),
    ReadingHistory(
      mangaId: '3',
      mangaTitle: 'Attack on Titan',
      coverUrl:
          'https://uploads.mangadex.org/covers/304ceac3-8cdb-4fe7-acf7-2b9b3c4c3172/563bd270-9068-4b46-9e03-47fd7b5d4f27.jpg',
      lastChapterId: '3_ch_139',
      lastChapterNumber: 139,
      lastReadAt: DateTime.now().subtract(const Duration(days: 1)),
      totalChapters: 139,
      chaptersRead: 139,
    ),
    ReadingHistory(
      mangaId: '12',
      mangaTitle: 'Chainsaw Man',
      coverUrl:
          'https://uploads.mangadex.org/covers/a77742b1-befd-49a4-bff5-1ad4e6b328d5/07656d79-f2d8-49c7-a27d-0b7e4e8e3a50.jpg',
      lastChapterId: '12_ch_145',
      lastChapterNumber: 145,
      lastReadAt: DateTime.now().subtract(const Duration(days: 3)),
      totalChapters: 170,
      chaptersRead: 145,
    ),
    ReadingHistory(
      mangaId: '11',
      mangaTitle: 'Vinland Saga',
      coverUrl:
          'https://uploads.mangadex.org/covers/d25f9b4e-6f04-4cf4-9e17-2a67e5d31cb2/a2f4e0db-70c5-4bc2-9d9d-cd86e6eedf64.jpg',
      lastChapterId: '11_ch_180',
      lastChapterNumber: 180,
      lastReadAt: DateTime.now().subtract(const Duration(days: 7)),
      totalChapters: 200,
      chaptersRead: 180,
    ),
    ReadingHistory(
      mangaId: '6',
      mangaTitle: 'Fullmetal Alchemist',
      coverUrl:
          'https://uploads.mangadex.org/covers/dbc9f9f8-be1f-45bf-8e6d-2c15bc63ae3e/2e5e2eef-1f8a-4f02-a3f1-41e88de7cd1b.jpg',
      lastChapterId: '6_ch_108',
      lastChapterNumber: 108,
      lastReadAt: DateTime.now().subtract(const Duration(days: 14)),
      totalChapters: 108,
      chaptersRead: 108,
    ),
  ];

  static final _fakeFavorites = <Manga>[
    const Manga(
      id: '1',
      title: 'One Piece',
      coverUrl:
          'https://uploads.mangadex.org/covers/a1c7c817-4e59-43b7-9365-09675a149a6f/1a5a20b4-05d9-4b77-9f85-7be7f21dc490.jpg',
      tags: ['Action', 'Adventure', 'Comedy', 'Fantasy'],
      status: MangaStatus.ongoing,
      averageRating: 4.8,
      totalChapters: 1100,
      author: 'Eiichiro Oda',
    ),
    const Manga(
      id: '3',
      title: 'Attack on Titan',
      coverUrl:
          'https://uploads.mangadex.org/covers/304ceac3-8cdb-4fe7-acf7-2b9b3c4c3172/563bd270-9068-4b46-9e03-47fd7b5d4f27.jpg',
      tags: ['Action', 'Drama', 'Horror', 'Mystery'],
      status: MangaStatus.completed,
      averageRating: 4.9,
      totalChapters: 139,
      author: 'Hajime Isayama',
    ),
    const Manga(
      id: '6',
      title: 'Fullmetal Alchemist',
      coverUrl:
          'https://uploads.mangadex.org/covers/dbc9f9f8-be1f-45bf-8e6d-2c15bc63ae3e/2e5e2eef-1f8a-4f02-a3f1-41e88de7cd1b.jpg',
      tags: ['Action', 'Adventure', 'Drama', 'Fantasy'],
      status: MangaStatus.completed,
      averageRating: 4.9,
      totalChapters: 108,
      author: 'Hiromu Arakawa',
    ),
    const Manga(
      id: '10',
      title: 'Hunter x Hunter',
      coverUrl:
          'https://uploads.mangadex.org/covers/2f5f3c84-5a44-43de-baaf-2fcd6a11e3ab/7dc3b75f-8e5e-4c9b-b1b0-3dce8cd48ee2.jpg',
      tags: ['Action', 'Adventure', 'Fantasy'],
      status: MangaStatus.hiatus,
      averageRating: 4.9,
      totalChapters: 400,
      author: 'Yoshihiro Togashi',
    ),
  ];

  @override
  Future<List<ReadingHistory>> getReadingHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_history);
  }

  @override
  Future<void> removeFromHistory(String mangaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _history.removeWhere((h) => h.mangaId == mangaId);
  }

  @override
  Future<void> saveProgress({
    required String mangaId,
    required String mangaTitle,
    required String coverUrl,
    required String chapterId,
    required double chapterNumber,
    required int totalChapters,
    required int chaptersRead,
    int lastPageRead = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _history.indexWhere((h) => h.mangaId == mangaId);
    final entry = ReadingHistory(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverUrl: coverUrl,
      lastChapterId: chapterId,
      lastChapterNumber: chapterNumber,
      lastReadAt: DateTime.now(),
      totalChapters: totalChapters,
      chaptersRead: chaptersRead,
      lastPageRead: lastPageRead,
    );
    if (idx >= 0) {
      _history[idx] = entry;
    } else {
      _history.insert(0, entry);
    }
  }

  @override
  Future<List<Manga>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_fakeFavorites);
  }

  @override
  Future<ReadingHistory?> getMostRecentlyRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_history.isEmpty) return null;
    return _history.first;
  }
}
