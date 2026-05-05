import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/manga.dart';
import 'manga_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchFilters {
  const SearchFilters({
    this.genres = const [],
    this.status,
    this.sortBy = 'relevance',
  });

  final List<String> genres;
  final MangaStatus? status;
  final String sortBy;

  SearchFilters copyWith({
    List<String>? genres,
    MangaStatus? status,
    bool clearStatus = false,
    String? sortBy,
  }) {
    return SearchFilters(
      genres: genres ?? this.genres,
      status: clearStatus ? null : (status ?? this.status),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersNotifier, SearchFilters>((ref) {
  return SearchFiltersNotifier();
});

class SearchFiltersNotifier extends StateNotifier<SearchFilters> {
  SearchFiltersNotifier() : super(const SearchFilters());

  void toggleGenre(String genre) {
    final genres = List<String>.from(state.genres);
    if (genres.contains(genre)) {
      genres.remove(genre);
    } else {
      genres.add(genre);
    }
    state = state.copyWith(genres: genres);
  }

  void setStatus(MangaStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(status: status);
    }
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const SearchFilters();
  }
}

final searchResultsProvider = FutureProvider<List<Manga>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filters = ref.watch(searchFiltersProvider);
  final repo = ref.watch(mangaRepositoryProvider);

  if (query.isEmpty && filters.genres.isEmpty && filters.status == null) {
    return repo.fetchLatest();
  }

  return repo.search(
    query,
    genres: filters.genres,
    status: filters.status,
    sortBy: filters.sortBy == 'relevance' ? null : filters.sortBy,
  );
});

const availableGenres = [
  'Action',
  'Adventure',
  'Comedy',
  'Drama',
  'Fantasy',
  'Horror',
  'Mystery',
  'Romance',
  'Sci-Fi',
  'Slice of Life',
  'Sports',
  'Supernatural',
  'Thriller',
  'Historical',
  'School Life',
  'Martial Arts',
  'Psychological',
];

const sortOptions = [
  ('relevance', 'Liên quan nhất'),
  ('rating', 'Đánh giá cao nhất'),
  ('title', 'Tiêu đề A-Z'),
  ('latest', 'Mới nhất'),
];
