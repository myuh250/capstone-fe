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

  Map<String, dynamic> _normalizeMangaJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['genres'] is List && normalized['tags'] == null) {
      normalized['tags'] = (normalized['genres'] as List)
          .map((g) => g is Map ? g['name'] as String? ?? '' : g.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (normalized['authors'] is List && normalized['author'] == null) {
      final authors = (normalized['authors'] as List)
          .map((a) => a is Map ? a['name'] as String? ?? '' : a.toString())
          .where((s) => s.isNotEmpty)
          .toList();
      if (authors.isNotEmpty) {
        normalized['author'] = authors.join(', ');
      }
    }
    return normalized;
  }

  List<Manga> _parseMangaList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Manga.fromJson(_normalizeMangaJson(e as Map<String, dynamic>)))
          .toList();
    }
    // paginated response: { content: [...], ... }
    final map = data as Map<String, dynamic>;
    final content = map['content'] as List<dynamic>? ?? map['data'] as List<dynamic>? ?? [];
    return content
        .map((e) => Manga.fromJson(_normalizeMangaJson(e as Map<String, dynamic>)))
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
    return Manga.fromJson(_normalizeMangaJson(data));
  }

  @override
  Future<Manga> getBySlug(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.mangaBySlug(slug));
    final map = response.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>? ?? map;
    return Manga.fromJson(_normalizeMangaJson(data));
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
          .map((e) => Manga.fromJson(_normalizeMangaJson(e as Map<String, dynamic>)))
          .toList();
      final totalPages = data['totalPages'] as int? ?? 1;
      return PaginatedResult(items: items, totalPages: totalPages);
    }
    final items = _parseMangaList(data);
    return PaginatedResult(items: items, totalPages: 1);
  }

  @override
  Future<List<Manga>> getRelated(String mangaId) async {
    const minItems = 12;
    final manga = await getById(mangaId);
    final List<Manga> related = [];
    final usedIds = <String>{mangaId};

    if (manga.tags.isNotEmpty) {
      final response = await _apiClient.get(
        ApiEndpoints.search,
        queryParameters: {'genres': manga.tags, 'size': 26},
      );
      final results = _parseMangaList(response.data);
      for (final m in results) {
        if (!usedIds.contains(m.id)) {
          related.add(m);
          usedIds.add(m.id);
        }
        if (related.length >= 24) break;
      }
    }

    if (related.length < minItems) {
      try {
        final response = await _apiClient.get(
          ApiEndpoints.mangasTrending,
          queryParameters: {'size': 26},
        );
        final trending = _parseMangaList(response.data);
        for (final m in trending) {
          if (!usedIds.contains(m.id)) {
            related.add(m);
            usedIds.add(m.id);
          }
          if (related.length >= minItems) break;
        }
      } catch (_) {}
    }

    return related;
  }

  @override
  Future<void> toggleFavorite(String mangaId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.libraryMe);
      final data = response.data;
      List<dynamic> entries = [];
      if (data is List) {
        entries = data;
      } else if (data is Map<String, dynamic>) {
        entries = data['content'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
      }
      final existing = entries.cast<Map<String, dynamic>>().where((e) {
        final manga = e['manga'] as Map<String, dynamic>?;
        return manga?['id'] == mangaId;
      }).firstOrNull;

      if (existing != null) {
        final entryId = existing['id'];
        await _apiClient.delete(ApiEndpoints.libraryDelete(entryId.toString()));
      } else {
        await _apiClient.post(
          ApiEndpoints.libraryAdd,
          data: {'mangaId': mangaId, 'status': 'FOLLOWING'},
        );
      }
    } catch (_) {
      await _apiClient.post(
        ApiEndpoints.libraryAdd,
        data: {'mangaId': mangaId, 'status': 'FOLLOWING'},
      );
    }
  }

  @override
  Future<bool> isFavorite(String mangaId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.libraryMe);
      final data = response.data;
      List<dynamic> entries = [];
      if (data is List) {
        entries = data;
      } else if (data is Map<String, dynamic>) {
        entries = data['content'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
      }
      return entries.cast<Map<String, dynamic>>().any((e) {
        final manga = e['manga'] as Map<String, dynamic>?;
        return manga?['id'] == mangaId;
      });
    } catch (_) {
      return false;
    }
  }
}
