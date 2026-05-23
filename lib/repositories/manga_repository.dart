import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/chapter.dart';
import '../models/manga.dart';

class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.totalPages});
  final List<T> items;
  final int totalPages;
}

abstract class MangaRepository {
  Future<List<Manga>> fetchFeatured();
  Future<List<Manga>> fetchLatest({int page = 0, int limit = 20});
  Future<List<Manga>> fetchPopular({int page = 0, int limit = 20});
  Future<List<Manga>> fetchCompleted({int page = 0, int limit = 20});
  Future<Manga> getById(String id);
  Future<Manga> getBySlug(String slug);
  Future<List<Manga>> search(
    String query, {
    List<String> genres = const [],
    MangaStatus? status,
    String? sortBy,
    int page = 0,
    int limit = 20,
  });
  Future<List<Chapter>> getChapters(String mangaId, {bool ascending = false});
  Future<List<Manga>> getRelated(String mangaId);
  Future<PaginatedResult<Manga>> searchPaginated(
    String query, {
    List<String> genres = const [],
    MangaStatus? status,
    String? sortBy,
    int page = 0,
    int limit = 24,
  });
  Future<void> toggleFavorite(String mangaId);
  Future<bool> isFavorite(String mangaId);
}

class RealMangaRepository implements MangaRepository {
  RealMangaRepository(this._apiClient);

  final ApiClient _apiClient;

  List<Manga> _parseMangaList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Manga.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // paginated response: { content: [...], ... }
    final map = data as Map<String, dynamic>;
    final content = map['content'] as List<dynamic>? ?? map['data'] as List<dynamic>? ?? [];
    return content
        .map((e) => Manga.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Manga>> fetchFeatured() async {
    final response = await _apiClient.get(
      ApiEndpoints.mangasTrending,
      queryParameters: {'size': 5},
    );
    return _parseMangaList(response.data);
  }

  @override
  Future<List<Manga>> fetchLatest({int page = 0, int limit = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.mangasRecent,
      queryParameters: {'page': page, 'size': limit},
    );
    return _parseMangaList(response.data);
  }

  @override
  Future<List<Manga>> fetchPopular({int page = 0, int limit = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.mangasTrending,
      queryParameters: {'size': limit},
    );
    return _parseMangaList(response.data);
  }

  @override
  Future<List<Manga>> fetchCompleted({int page = 0, int limit = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.mangas,
      queryParameters: {'status': 'completed', 'page': page, 'size': limit},
    );
    return _parseMangaList(response.data);
  }

  @override
  Future<Manga> getById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.mangaById(id));
    final map = response.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? map;
    return Manga.fromJson(data);
  }

  @override
  Future<Manga> getBySlug(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.mangaBySlug(slug));
    final map = response.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? map;
    return Manga.fromJson(data);
  }

  @override
  Future<List<Manga>> search(
    String query, {
    List<String> genres = const [],
    MangaStatus? status,
    String? sortBy,
    int page = 0,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'size': limit,
    };
    if (query.isNotEmpty) params['query'] = query;
    if (genres.isNotEmpty) params['genres'] = genres;
    if (status != null) params['status'] = status.name;
    if (sortBy != null) params['sortBy'] = sortBy;

    final response = await _apiClient.get(
      ApiEndpoints.search,
      queryParameters: params,
    );
    return _parseMangaList(response.data);
  }

  @override
  Future<List<Chapter>> getChapters(String mangaId, {bool ascending = false}) async {
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
        .toList();
    if (ascending) return chapters.reversed.toList();
    return chapters;
  }

  @override
  Future<PaginatedResult<Manga>> searchPaginated(
    String query, {
    List<String> genres = const [],
    MangaStatus? status,
    String? sortBy,
    int page = 0,
    int limit = 24,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'size': limit,
    };
    if (query.isNotEmpty) params['query'] = query;
    if (genres.isNotEmpty) params['genres'] = genres;
    if (status != null) params['status'] = status.name;
    if (sortBy != null) params['sortBy'] = sortBy;

    final response = await _apiClient.get(
      ApiEndpoints.search,
      queryParameters: params,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final content = data['data'] as List<dynamic>? ??
          data['content'] as List<dynamic>? ??
          [];
      final items = content
          .map((e) => Manga.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalPages = data['totalPages'] as int? ?? 1;
      return PaginatedResult(items: items, totalPages: totalPages);
    }
    final items = _parseMangaList(data);
    return PaginatedResult(items: items, totalPages: 1);
  }

  @override
  Future<List<Manga>> getRelated(String mangaId) async {
    final manga = await getById(mangaId);
    if (manga.tags.isNotEmpty) {
      final response = await _apiClient.get(
        ApiEndpoints.search,
        queryParameters: {'genres': manga.tags, 'size': 26},
      );
      final results = _parseMangaList(response.data);
      final filtered = results.where((m) => m.id != mangaId).take(24).toList();
      if (filtered.isNotEmpty) return filtered;
    }
    final response = await _apiClient.get(
      ApiEndpoints.mangasTrending,
      queryParameters: {'size': 26},
    );
    final all = _parseMangaList(response.data);
    return all.where((m) => m.id != mangaId).take(24).toList();
  }

  @override
  Future<void> toggleFavorite(String mangaId) async {
    // Implemented via library: add/remove from FOLLOWING status
    // This is a best-effort toggle; check library_repository for full control
    await _apiClient.post(
      ApiEndpoints.libraryAdd,
      data: {'mangaId': mangaId, 'status': 'FOLLOWING'},
    );
  }

  @override
  Future<bool> isFavorite(String mangaId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.libraryMeByStatus('FOLLOWING'),
      );
      final list = _parseMangaList(response.data);
      return list.any((m) => m.id == mangaId);
    } catch (_) {
      return false;
    }
  }
}
