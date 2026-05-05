import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/manga.dart';
import '../models/user.dart';
import '../repositories/manga_repository.dart';
import 'manga_providers.dart';

class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.totalManga,
    required this.totalChapters,
    required this.totalReports,
    required this.newUsersToday,
    required this.activeReaders,
  });

  final int totalUsers;
  final int totalManga;
  final int totalChapters;
  final int totalReports;
  final int newUsersToday;
  final int activeReaders;
}

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return const AdminStats(
    totalUsers: 12458,
    totalManga: 384,
    totalChapters: 48293,
    totalReports: 23,
    newUsersToday: 142,
    activeReaders: 2341,
  );
});

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  return AdminUsersNotifier();
});

class AdminUsersState {
  const AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.roleFilter,
    this.statusFilter,
  });

  final List<User> users;
  final bool isLoading;
  final Object? error;
  final String searchQuery;
  final UserRole? roleFilter;
  final UserStatus? statusFilter;

  AdminUsersState copyWith({
    List<User>? users,
    bool? isLoading,
    Object? error,
    String? searchQuery,
    UserRole? roleFilter,
    bool clearRoleFilter = false,
    UserStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  AdminUsersNotifier() : super(const AdminUsersState(isLoading: true)) {
    _load();
  }

  static final _fakeUsers = List.generate(
    20,
    (i) => User(
      id: 'user_$i',
      email: 'user$i@example.com',
      displayName: 'User ${i + 1}',
      role: i == 0 ? UserRole.admin : UserRole.user,
      status: i == 5 ? UserStatus.banned : UserStatus.active,
      isPremium: i % 3 == 0,
      createdAt: DateTime.now().subtract(Duration(days: i * 15)),
    ),
  );

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(users: _fakeUsers, isLoading: false);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> changeRole(String userId, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = state.users.map((u) {
      return u.id == userId ? u.copyWith(role: role) : u;
    }).toList();
    state = state.copyWith(users: updated);
  }

  Future<void> toggleBan(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = state.users.map((u) {
      if (u.id != userId) return u;
      return u.copyWith(
        status:
            u.status == UserStatus.banned ? UserStatus.active : UserStatus.banned,
      );
    }).toList();
    state = state.copyWith(users: updated);
  }

  List<User> get filteredUsers {
    var result = state.users;
    if (state.searchQuery.isNotEmpty) {
      result = result
          .where(
            (u) =>
                u.displayName
                    .toLowerCase()
                    .contains(state.searchQuery.toLowerCase()) ||
                u.email
                    .toLowerCase()
                    .contains(state.searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (state.roleFilter != null) {
      result = result.where((u) => u.role == state.roleFilter).toList();
    }
    if (state.statusFilter != null) {
      result = result.where((u) => u.status == state.statusFilter).toList();
    }
    return result;
  }
}

final adminMangaProvider =
    StateNotifierProvider<AdminMangaNotifier, AdminMangaState>((ref) {
  return AdminMangaNotifier(ref.read(mangaRepositoryProvider));
});

class AdminMangaState {
  const AdminMangaState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  final List<Manga> items;
  final bool isLoading;
  final Object? error;
  final String searchQuery;

  AdminMangaState copyWith({
    List<Manga>? items,
    bool? isLoading,
    Object? error,
    String? searchQuery,
  }) {
    return AdminMangaState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminMangaNotifier extends StateNotifier<AdminMangaState> {
  AdminMangaNotifier(this._repository)
      : super(const AdminMangaState(isLoading: true)) {
    _load();
  }

  final MangaRepository _repository;

  Future<void> _load() async {
    try {
      final mangas = await _repository.fetchLatest(limit: 50);
      state = state.copyWith(items: mangas, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> deleteManga(String mangaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = state.items.where((m) => m.id != mangaId).toList();
    state = state.copyWith(items: updated);
  }

  List<Manga> get filteredManga {
    if (state.searchQuery.isEmpty) return state.items;
    return state.items
        .where(
          (m) => m.title
              .toLowerCase()
              .contains(state.searchQuery.toLowerCase()),
        )
        .toList();
  }
}
