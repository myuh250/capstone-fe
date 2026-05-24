import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/chapter.dart';
import '../models/manga.dart';
import '../repositories/manga_repository.dart';

final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  return RealMangaRepository(ref.watch(apiClientProvider));
});

final featuredMangaProvider = FutureProvider<List<Manga>>((ref) {
  // keepAlive: cache survives navigation so we don't refetch every time user
  // goes to manga detail and comes back.
  ref.keepAlive();
  return ref.read(mangaRepositoryProvider).fetchFeatured();
});

final latestMangaProvider = FutureProvider<List<Manga>>((ref) {
  ref.keepAlive();
  return ref.read(mangaRepositoryProvider).fetchLatest(limit: 40);
});

final popularMangaProvider = FutureProvider<List<Manga>>((ref) {
  ref.keepAlive();
  return ref.read(mangaRepositoryProvider).fetchPopular(limit: 40);
});

final completedMangaProvider = FutureProvider<List<Manga>>((ref) {
  ref.keepAlive();
  return ref.read(mangaRepositoryProvider).fetchCompleted(limit: 40);
});

final mangaDetailProvider =
    FutureProvider.family<Manga, String>((ref, id) async {
  ref.keepAlive();
  return ref.read(mangaRepositoryProvider).getById(id);
});

final mangaBySlugProvider =
    FutureProvider.family<Manga, String>((ref, slug) async {
  ref.keepAlive();
  return ref.read(mangaRepositoryProvider).getBySlug(slug);
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

  // Sentinel used to distinguish "explicitly pass null" from "not provided".
  static const _keep = Object();

  ChapterListState copyWith({
    List<Chapter>? chapters,
    bool? isLoading,
    Object? error = _keep,
    bool? ascending,
  }) {
    return ChapterListState(
      chapters: chapters ?? this.chapters,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _keep) ? this.error : error,
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
      state = state.copyWith(chapters: chapters, isLoading: false, error: null);
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

class AllMangaState {
  const AllMangaState({
    this.items = const [],
    this.isLoading = false,
    this.page = 0,
    this.hasMore = true,
  });

  final List<Manga> items;
  final bool isLoading;
  final int page;
  final bool hasMore;

  AllMangaState copyWith({
    List<Manga>? items,
    bool? isLoading,
    int? page,
    bool? hasMore,
  }) {
    return AllMangaState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final allMangaProvider =
    StateNotifierProvider<AllMangaNotifier, AllMangaState>(
  (ref) => AllMangaNotifier(ref.read(mangaRepositoryProvider)),
);

class AllMangaNotifier extends StateNotifier<AllMangaState> {
  AllMangaNotifier(this._repository) : super(const AllMangaState()) {
    loadMore();
  }

  final MangaRepository _repository;
  static const _pageSize = 20;

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final newItems = await _repository.fetchLatest(
        page: state.page,
        limit: _pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...newItems],
        page: state.page + 1,
        isLoading: false,
        hasMore: newItems.length >= _pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
