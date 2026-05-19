import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/manga.dart';
import '../models/reading_history.dart';
import '../repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return RealLibraryRepository(ref.watch(apiClientProvider));
});

final readingHistoryProvider =
    StateNotifierProvider<ReadingHistoryNotifier, AsyncValue<List<ReadingHistory>>>(
  (ref) => ReadingHistoryNotifier(ref.read(libraryRepositoryProvider)),
);

class ReadingHistoryNotifier
    extends StateNotifier<AsyncValue<List<ReadingHistory>>> {
  ReadingHistoryNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final LibraryRepository _repo;

  Future<void> _load() async {
    try {
      final history = await _repo.getReadingHistory();
      state = AsyncValue.data(history);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeEntry(String mangaId) async {
    await _repo.removeFromHistory(mangaId);
    await _load();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Manga>>>(
  (ref) => FavoritesNotifier(ref.read(libraryRepositoryProvider)),
);

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Manga>>> {
  FavoritesNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final LibraryRepository _repo;

  Future<void> _load() async {
    try {
      final favs = await _repo.getFavorites();
      state = AsyncValue.data(favs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}

final continueReadingProvider = FutureProvider<ReadingHistory?>((ref) {
  return ref.watch(libraryRepositoryProvider).getMostRecentlyRead();
});
