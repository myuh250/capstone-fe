import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chapter.dart';
import '../models/manga.dart';
import '../repositories/manga_repository.dart';

final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  return FakeMangaRepository();
});

final featuredMangaProvider = FutureProvider<List<Manga>>((ref) {
  return ref.watch(mangaRepositoryProvider).fetchFeatured();
});

final latestMangaProvider = FutureProvider<List<Manga>>((ref) {
  return ref.watch(mangaRepositoryProvider).fetchLatest();
});

final popularMangaProvider = FutureProvider<List<Manga>>((ref) {
  return ref.watch(mangaRepositoryProvider).fetchPopular();
});

final completedMangaProvider = FutureProvider<List<Manga>>((ref) {
  return ref.watch(mangaRepositoryProvider).fetchCompleted();
});

final mangaDetailProvider =
    FutureProvider.family<Manga, String>((ref, id) async {
  return ref.watch(mangaRepositoryProvider).getById(id);
});

final chapterListProvider =
    StateNotifierProvider.family<ChapterListNotifier, ChapterListState, String>(
  (ref, mangaId) {
    return ChapterListNotifier(ref.read(mangaRepositoryProvider), mangaId);
  },
);

class ChapterListState {
  const ChapterListState({
    this.chapters = const [],
    this.isLoading = false,
    this.error,
    this.ascending = false,
  });

  final List<Chapter> chapters;
  final bool isLoading;
  final Object? error;
  final bool ascending;

  ChapterListState copyWith({
    List<Chapter>? chapters,
    bool? isLoading,
    Object? error,
    bool? ascending,
  }) {
    return ChapterListState(
      chapters: chapters ?? this.chapters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      ascending: ascending ?? this.ascending,
    );
  }
}

class ChapterListNotifier extends StateNotifier<ChapterListState> {
  ChapterListNotifier(this._repository, this._mangaId)
      : super(const ChapterListState(isLoading: true)) {
    _load();
  }

  final MangaRepository _repository;
  final String _mangaId;

  Future<void> _load() async {
    try {
      final chapters = await _repository.getChapters(
        _mangaId,
        ascending: state.ascending,
      );
      state = state.copyWith(chapters: chapters, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> toggleSort() async {
    state = state.copyWith(ascending: !state.ascending, isLoading: true);
    await _load();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _load();
  }
}

final relatedMangaProvider =
    FutureProvider.family<List<Manga>, String>((ref, mangaId) {
  return ref.watch(mangaRepositoryProvider).getRelated(mangaId);
});

final favoriteProvider =
    StateNotifierProvider.family<FavoriteNotifier, bool, String>(
  (ref, mangaId) {
    return FavoriteNotifier(ref.read(mangaRepositoryProvider), mangaId);
  },
);

class FavoriteNotifier extends StateNotifier<bool> {
  FavoriteNotifier(this._repository, this._mangaId) : super(false) {
    _init();
  }

  final MangaRepository _repository;
  final String _mangaId;

  Future<void> _init() async {
    final isFav = await _repository.isFavorite(_mangaId);
    state = isFav;
  }

  Future<void> toggle() async {
    state = !state;
    await _repository.toggleFavorite(_mangaId);
  }
}
