import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/manga.dart';
import '../models/user.dart';
import '../repositories/admin_repository.dart';
import '../repositories/manga_repository.dart';
import 'manga_providers.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});

// ─── Dashboard Stats ───

final adminStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getDashboardStats();
});

// ─── User Management ───

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  return AdminUsersNotifier(ref.read(adminRepositoryProvider));
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
  AdminUsersNotifier(this._repo) : super(const AdminUsersState(isLoading: true)) {
    _load();
  }

  final AdminRepository _repo;

  Future<void> _load() async {
    try {
      final users = await _repo.getUsers(
        query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _load();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setRoleFilter(UserRole? role) {
    if (role == null) {
      state = state.copyWith(clearRoleFilter: true);
    } else {
      state = state.copyWith(roleFilter: role);
    }
  }

  void setStatusFilter(UserStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  Future<void> toggleBan(String userId) async {
    final user = state.users.firstWhere((u) => u.id == userId);
    try {
      if (user.status == UserStatus.banned) {
        final updated = await _repo.reactivateUser(userId);
        _replaceUser(updated);
      } else {
        final updated = await _repo.deactivateUser(userId);
        _replaceUser(updated);
      }
    } catch (e) {
      state = state.copyWith(error: e);
    }
  }

  Future<void> changeRole(String userId, UserRole role) async {
    // Backend uses deactivate/reactivate; role change maps to ban/unban
    // For actual role change, this would need a dedicated endpoint
    // For now, keep local state consistent
    final updated = state.users.map((u) {
      return u.id == userId ? u.copyWith(role: role) : u;
    }).toList();
    state = state.copyWith(users: updated);
  }

  void _replaceUser(User updated) {
    final users = state.users.map((u) {
      return u.id == updated.id ? updated : u;
    }).toList();
    state = state.copyWith(users: users);
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

// ─── Manga Management ───

final adminMangaProvider =
    StateNotifierProvider<AdminMangaNotifier, AdminMangaState>((ref) {
  return AdminMangaNotifier(
    ref.read(mangaRepositoryProvider),
    ref.read(adminRepositoryProvider),
  );
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
  AdminMangaNotifier(this._mangaRepo, this._adminRepo)
      : super(const AdminMangaState(isLoading: true)) {
    _load();
  }

  final MangaRepository _mangaRepo;
  final AdminRepository _adminRepo;

  Future<void> _load() async {
    try {
      final mangas = await _mangaRepo.fetchLatest(limit: 50);
      state = state.copyWith(items: mangas, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> createManga({
    required String title,
    required String description,
    required String status,
    String? coverUrl,
    List<String>? genreNames,
    List<String>? authorNames,
  }) async {
    try {
      await _adminRepo.createManga(
        title: title,
        description: description,
        status: status,
        coverUrl: coverUrl,
        genreNames: genreNames,
        authorNames: authorNames,
      );
      await _load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e);
      return false;
    }
  }

  Future<bool> updateManga({
    required String mangaId,
    String? title,
    String? description,
    String? status,
    String? coverUrl,
  }) async {
    try {
      await _adminRepo.updateManga(
        mangaId: mangaId,
        title: title,
        description: description,
        status: status,
        coverUrl: coverUrl,
      );
      await _load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e);
      return false;
    }
  }

  Future<void> deleteManga(String mangaId) async {
    try {
      await _adminRepo.deleteManga(mangaId);
      final updated = state.items.where((m) => m.id != mangaId).toList();
      state = state.copyWith(items: updated);
    } catch (e) {
      state = state.copyWith(error: e);
    }
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

// ─── Sync Dashboard ───

final syncDashboardProvider = FutureProvider<SyncDashboard>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getSyncDashboard();
});

final syncLogsProvider = FutureProvider.family<SyncLogsResult, (String?, int, int)>(
    (ref, params) async {
  final (jobType, page, size) = params;
  final repo = ref.read(adminRepositoryProvider);
  return repo.getSyncLogsPaged(jobType: jobType, page: page, size: size);
});

// ─── AI Moderation ───

final aiModerationResultsProvider =
    FutureProvider.family<List<AiModerationResult>, bool>((ref, flaggedOnly) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getAiModerationResults(flaggedOnly: flaggedOnly);
});

final aiModerationPendingProvider =
    FutureProvider<List<AiModerationResult>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getAiModerationPending();
});

final aiModerationStatsProvider = FutureProvider<AiModerationStats>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getAiModerationStats();
});
