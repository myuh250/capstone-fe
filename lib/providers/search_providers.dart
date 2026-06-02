import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/manga.dart';
import '../repositories/manga_repository.dart';
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

final searchPageProvider = StateProvider<int>((ref) => 0);

const searchPageSize = 24;

final searchResultsProvider = FutureProvider<PaginatedResult<Manga>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filters = ref.watch(searchFiltersProvider);
  final page = ref.watch(searchPageProvider);
  final repo = ref.watch(mangaRepositoryProvider);

  return repo.searchPaginated(
    query,
    genres: filters.genres,
    status: filters.status,
    sortBy: filters.sortBy == 'relevance' ? null : filters.sortBy,
    page: page,
    limit: searchPageSize,
  );
});

final allGenresProvider = FutureProvider<List<String>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiEndpoints.genres);
  final list = response.data as List<dynamic>;
  return list
      .map((e) => (e as Map<String, dynamic>)['name'] as String)
      .toList()
    ..sort();
});

const sortOptions = [
  ('relevance', 'Most Relevant'),
  ('rating', 'Highest Rated'),
  ('title', 'Title A-Z'),
  ('latest', 'Latest'),
];
