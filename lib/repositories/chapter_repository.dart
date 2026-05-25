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

    // Backend proxy URLs are relative paths like "/api/proxy/image?chapterId=X&page=N".
    // CachedNetworkImage needs absolute URLs, so we prepend the server origin.
    // ApiEndpoints.baseUrl is e.g. "http://10.0.2.2:9000/api" — strip the "/api" suffix.
    final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/api$'), '');

    return urls.asMap().entries.map((entry) {
      final idx = entry.key;
      final raw = entry.value;
      final String rawUrl =
          raw is String ? raw : (raw as Map<String, dynamic>)['url'] as String;
      // Make relative URLs absolute; leave already-absolute URLs untouched.
      final String imageUrl =
          rawUrl.startsWith('http') ? rawUrl : '$base$rawUrl';
      return ChapterPage(
        id: '${chapterId}_page_${idx + 1}',
        chapterId: chapterId,
        pageNumber: idx + 1,
        imageUrl: imageUrl,
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
        'page': currentPage,
      },
    );
  }
}
