import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/manga.dart';
import 'manga_providers.dart';

class Recommendation {
  const Recommendation({required this.manga, this.becauseOf});

  final Manga manga;
  final String? becauseOf;
}

const _reasonLabels = {
  'similar_to_your_reads': 'Similar to what you\'ve read',
  'readers_like_you_enjoyed': 'Readers like you enjoyed this',
  'matches_your_genre_taste': 'Matches your taste',
  'popular_now': 'Popular now',
};

final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(
      ApiEndpoints.recommendations,
      queryParameters: {'limit': 40},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['recommendations'] as List<dynamic>? ?? [];
    return list.map((e) {
      final item = e as Map<String, dynamic>;
      return Recommendation(
        manga: Manga(
          id: item['mangaId'] as String,
          title: item['title'] as String? ?? '',
          slug: item['slug'] as String?,
          coverUrl: item['coverUrl'] as String? ?? '',
          averageRating: (item['averageRating'] as num?)?.toDouble() ?? 0.0,
        ),
        becauseOf: _reasonLabels[item['reason']] ?? item['reason'] as String?,
      );
    }).toList();
  } catch (_) {
    final repo = ref.read(mangaRepositoryProvider);
    final manga = await repo.fetchPopular(limit: 40);
    return manga.map((m) => Recommendation(manga: m, becauseOf: 'Popular now')).toList();
  }
});

final mangaRecommendationsProvider =
    FutureProvider.family<List<Recommendation>, String>((ref, mangaId) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get(
      ApiEndpoints.recommendations,
      queryParameters: {'limit': 14},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['recommendations'] as List<dynamic>? ?? [];
    final recs = list
        .where((e) => (e as Map<String, dynamic>)['mangaId'] != mangaId)
        .take(12)
        .map((e) {
      final item = e as Map<String, dynamic>;
      return Recommendation(
        manga: Manga(
          id: item['mangaId'] as String,
          title: item['title'] as String? ?? '',
          slug: item['slug'] as String?,
          coverUrl: item['coverUrl'] as String? ?? '',
          averageRating: (item['averageRating'] as num?)?.toDouble() ?? 0.0,
        ),
        becauseOf: _reasonLabels[item['reason']] ?? item['reason'] as String?,
      );
    }).toList();
    if (recs.isNotEmpty) return recs;
  } catch (_) {}
  final repo = ref.read(mangaRepositoryProvider);
  final popular = await repo.fetchPopular(limit: 14);
  return popular
      .where((m) => m.id != mangaId)
      .take(12)
      .map((m) => Recommendation(manga: m, becauseOf: 'Popular now'))
      .toList();
});
