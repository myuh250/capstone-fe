# Code Conventions

## Dart / Flutter

### Naming

| Type | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `manga_card.dart`, `auth_repository.dart` |
| Classes | PascalCase | `MangaDetailScreen`, `AuthRepository` |
| Variables, functions | camelCase | `mangaList`, `fetchChapters()` |
| Constants | camelCase or SCREAMING_SNAKE | `defaultPageSize`, `API_BASE_URL` |
| Enums | PascalCase + camelCase values | `MangaStatus.ongoing` |
| Providers | camelCase + Provider suffix | `mangaListProvider`, `authStateProvider` |
| Private members | `_` prefix | `_isLoading`, `_fetchData()` |

### File Organization

```dart
// 1. Dart/Flutter imports
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 3. Project imports (relative)
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/manga_card.dart';
```

### Widget Structure

```dart
class MangaCard extends StatelessWidget {
  const MangaCard({
    super.key,
    required this.manga,
    this.onTap,
    this.showRating = true,
  });

  final Manga manga;
  final VoidCallback? onTap;
  final bool showRating;

  @override
  Widget build(BuildContext context) {
    // Keep build methods short — extract helper widgets, not methods
    return ...;
  }
}
```

### Rules

- One public class per file (matching filename)
- `const` constructors on all widgets that can be const
- Named parameters for widget constructors (positional only for simple data classes)
- Use `super.key` not `Key? key`
- Prefer `final` over `var` — always
- No `dynamic` unless interfacing with untyped JSON
- Use `switch` expressions (Dart 3) over if-else chains for enums
- Trailing commas on all argument lists and collection literals
- Max line length: 80 characters (Dart default)

### Riverpod Conventions

```dart
// Provider file: one file per feature domain
// e.g., providers/manga_providers.dart

// Async data → AsyncNotifierProvider (generated)
@riverpod
class MangaDetail extends _$MangaDetail {
  @override
  Future<Manga> build(String id) => ref.read(mangaRepositoryProvider).getById(id);
}

// Simple state → NotifierProvider
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() => state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

// Read-only computed → plain provider
@riverpod
int totalChapters(ref) => ref.watch(mangaDetailProvider).valueOrNull?.totalChapters ?? 0;
```

### Error Handling

```dart
// Repository layer: catch Dio errors, throw typed exceptions
class MangaRepository {
  Future<Manga> getById(String id) async {
    try {
      final response = await _client.get('/manga/$id');
      return Manga.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

// UI layer: .when() handles all states
ref.watch(mangaDetailProvider(id)).when(
  data: (manga) => MangaDetailView(manga: manga),
  loading: () => const MangaDetailSkeleton(),
  error: (e, _) => ErrorView(
    message: e is ApiException ? e.userMessage : 'Something went wrong',
    onRetry: () => ref.invalidate(mangaDetailProvider(id)),
  ),
);
```

## Git

### Branch Naming

```
feature/FR-XX-short-description    # e.g., feature/FR-05-manga-list
fix/FR-XX-bug-description          # e.g., fix/FR-08-reader-image-loading
chore/description                  # e.g., chore/update-dependencies
```

### Commit Messages

```
feat(FR-05): implement manga grid with infinite scroll
fix(FR-08): resolve image preloading race condition
refactor(core): extract responsive breakpoints to shared builder
chore: update riverpod to 2.6.0
```

Format: `type(scope): description` — scope maps to FR-XX or module name.

## Testing

- Unit tests for repositories and providers
- Widget tests for shared widgets (MangaCard, StarRating, etc.)
- Name test files `*_test.dart` next to source or in `test/` mirror
- Use `mocktail` for mocking
