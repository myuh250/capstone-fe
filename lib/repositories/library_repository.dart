import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/manga.dart';
import '../models/reading_history.dart';

abstract class LibraryRepository {
  Future<List<ReadingHistory>> getReadingHistory();
  Future<void> removeFromHistory(String historyId);
  Future<void> clearAllHistory();
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

class RealLibraryRepository implements LibraryRepository {
  RealLibraryRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ReadingHistory>> getReadingHistory() async {
    final response = await _apiClient.get(ApiEndpoints.historyProgress);
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) => ReadingHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> removeFromHistory(String historyId) async {
    await _apiClient.delete(ApiEndpoints.historyDelete(historyId));
  }

  @override
  Future<void> clearAllHistory() async {
    await _apiClient.delete(ApiEndpoints.historyDeleteAll);
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
    await _apiClient.post(
      ApiEndpoints.historyProgress,
      data: {
        'mangaId': mangaId,
        'chapterId': chapterId,
        'page': lastPageRead,
      },
    );
  }

  @override
  Future<List<Manga>> getFavorites() async {
    final response = await _apiClient.get(
      ApiEndpoints.libraryMeByStatus('FOLLOWING'),
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) {
          // Library entries may wrap the manga; try unwrapping
          final item = e as Map<String, dynamic>;
          final manga = item['manga'] as Map<String, dynamic>? ?? item;
          return Manga.fromJson(manga);
        })
        .toList();
  }

  @override
  Future<ReadingHistory?> getMostRecentlyRead() async {
    final history = await getReadingHistory();
    if (history.isEmpty) return null;
    return history.reduce(
      (a, b) => a.lastReadAt.isAfter(b.lastReadAt) ? a : b,
    );
  }
}
