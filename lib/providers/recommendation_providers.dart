import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/manga.dart';
import 'manga_providers.dart';

class Recommendation {
  const Recommendation({required this.manga, this.becauseOf});

  final Manga manga;
  final String? becauseOf;
}

final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final repo = ref.watch(mangaRepositoryProvider);
  final manga = await repo.fetchPopular();
  return manga.take(8).toList().asMap().entries.map((e) {
    final reasons = [
      'Vì bạn đã đọc One Piece',
      'Vì bạn thích thể loại Action',
      'Vì bạn đã đọc Attack on Titan',
      'Phổ biến trong tuần này',
    ];
    return Recommendation(
      manga: e.value,
      becauseOf: reasons[e.key % reasons.length],
    );
  }).toList();
});

final mangaRecommendationsProvider =
    FutureProvider.family<List<Recommendation>, String>((ref, mangaId) async {
  await Future.delayed(const Duration(milliseconds: 400));
  final repo = ref.watch(mangaRepositoryProvider);
  final related = await repo.getRelated(mangaId);
  return related.take(6).map((m) => Recommendation(
        manga: m,
        becauseOf: 'Tương tự manga bạn đang xem',
      )).toList();
});
