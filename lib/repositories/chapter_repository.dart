import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
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

class RealChapterRepository implements ChapterRepository {
  RealChapterRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ChapterPage>> getPages(String chapterId) async {
    // Returns a list of proxy image URLs from the BE
    final response = await _apiClient.get(
      ApiEndpoints.chapterImages(chapterId),
    );
    final data = response.data;
    List<dynamic> urls;
    if (data is List) {
      urls = data;
    } else {
      urls = (data as Map<String, dynamic>)['images'] as List<dynamic>? ?? [];
    }
    return urls.asMap().entries.map((entry) {
      final idx = entry.key;
      final url = entry.value;
      return ChapterPage(
        id: '${chapterId}_page_${idx + 1}',
        chapterId: chapterId,
        pageNumber: idx + 1,
        imageUrl: url is String ? url : (url as Map<String, dynamic>)['url'] as String,
      );
    }).toList();
  }

  @override
  Future<Chapter?> getPreviousChapter(
    String mangaId,
    double chapterNumber,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.chaptersByManga(mangaId),
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    final chapters = list
        .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    final idx = chapters.indexWhere((c) => c.number == chapterNumber);
    if (idx <= 0) return null;
    return chapters[idx - 1];
  }

  @override
  Future<Chapter?> getNextChapter(
    String mangaId,
    double chapterNumber,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.chaptersByManga(mangaId),
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    final chapters = list
        .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    final idx = chapters.indexWhere((c) => c.number == chapterNumber);
    if (idx < 0 || idx >= chapters.length - 1) return null;
    return chapters[idx + 1];
  }

  @override
  Future<void> saveReadingProgress(
    String mangaId,
    String chapterId,
    int currentPage,
  ) async {
    await _apiClient.post(
      ApiEndpoints.historyProgress,
      data: {
        'mangaId': mangaId,
        'chapterId': chapterId,
        'lastPageRead': currentPage,
      },
    );
  }
}
