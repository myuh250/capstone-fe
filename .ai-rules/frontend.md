# Frontend Rules — Flutter

## Design Direction

The UI must closely follow **MangaDex** (https://mangadex.org) as the visual reference:

### Color Palette (MangaDex-inspired)

```dart
// Dark theme (primary — MangaDex default)
static const background    = Color(0xFF1C1C1C); // page background
static const surface       = Color(0xFF2C2C2C); // cards, panels
static const surfaceAlt    = Color(0xFF363636); // elevated surfaces, hover
static const primary       = Color(0xFFFF6740); // MangaDex orange — buttons, links, active states
static const primaryDark   = Color(0xFFE85D39); // pressed state
static const textPrimary   = Color(0xFFFFFFFF); // headings, body
static const textSecondary = Color(0xFFA0A0A0); // labels, captions, metadata
static const divider       = Color(0xFF3D3D3D); // borders, separators
static const tagBg         = Color(0xFF404040); // genre tags background
static const statusGreen   = Color(0xFF2EA44F); // ongoing status
static const statusBlue    = Color(0xFF3B82F6); // completed status
static const ratingYellow  = Color(0xFFFBBF24); // star rating

// Light theme
static const bgLight       = Color(0xFFF9F9F9);
static const surfaceLight  = Color(0xFFFFFFFF);
static const textLight     = Color(0xFF1C1C1C);
```

### Typography

- Primary font: **Inter** or **Nunito Sans** (clean, readable — matches MangaDex's sans-serif style)
- Use `google_fonts` package
- Scale: 12 (caption) / 14 (body) / 16 (subtitle) / 20 (title) / 24 (heading) / 32 (display)
- Font weight: 400 (body), 600 (subtitle/label), 700 (heading)

### Layout Principles (follow MangaDex)

- **Grid-based manga cards**: 2 columns mobile, 3-4 tablet, 5-6 desktop. Card = cover image + title + tags below
- **Left sidebar navigation** on desktop/tablet; bottom navigation bar on mobile
- **Top search bar** always visible, with filter chips below
- **Card hover effects**: subtle elevation + border highlight (web/desktop)
- **Dense information display**: MangaDex packs metadata (status, rating, chapter count, tags) compactly — replicate this density
- **Tag pills**: rounded rectangles with muted background, small text
- **Cover images**: 2:3 aspect ratio (standard manga cover), rounded corners (4-8px)
- **Reading view**: full-width images, minimal chrome, dark background
- **Spacing**: 8px base unit (8, 12, 16, 24, 32)

## Architecture

### State Management: Riverpod

Use `flutter_riverpod` as the sole state management solution.

```dart
// Prefer code-generation style with riverpod_annotation
@riverpod
class MangaList extends _$MangaList {
  @override
  Future<List<Manga>> build() => ref.read(mangaRepositoryProvider).fetchAll();
}

// In widgets
final mangaAsync = ref.watch(mangaListProvider);
return mangaAsync.when(
  data: (list) => MangaGrid(items: list),
  loading: () => const MangaGridSkeleton(),
  error: (e, _) => ErrorView(message: e.toString()),
);
```

### Routing: go_router

```dart
// Declarative routing with GoRouter
// Use ShellRoute for persistent navigation (sidebar/bottom bar)
GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/manga/:id', builder: (_, state) => MangaDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/manga/:id/chapter/:chapterId', builder: (_, state) => ReaderScreen(...)),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
        GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
      ],
    ),
  ],
);
```

### Folder Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + GoRouter + ProviderScope
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            # Color constants (MangaDex palette)
│   │   ├── app_typography.dart        # Text styles
│   │   ├── app_theme.dart             # ThemeData (light + dark)
│   │   └── app_spacing.dart           # Spacing constants (8px grid)
│   ├── network/
│   │   ├── api_client.dart            # Dio instance, interceptors
│   │   ├── api_endpoints.dart         # Endpoint constants
│   │   └── api_exceptions.dart        # Typed exceptions
│   ├── storage/
│   │   └── local_storage.dart         # SharedPreferences / Hive wrapper
│   ├── router/
│   │   └── app_router.dart            # GoRouter config
│   └── utils/
│       ├── extensions.dart            # Dart/Flutter extensions
│       └── constants.dart             # App-wide constants
├── models/                            # Data classes (freezed)
│   ├── manga.dart
│   ├── chapter.dart
│   ├── user.dart
│   ├── comment.dart
│   ├── rating.dart
│   └── ...
├── repositories/                      # Data layer — abstract + implementation
│   ├── manga_repository.dart
│   ├── auth_repository.dart
│   ├── chapter_repository.dart
│   ├── user_repository.dart
│   └── ...
├── providers/                         # Riverpod providers (riverpod_annotation)
│   ├── manga_providers.dart
│   ├── auth_providers.dart
│   ├── reader_providers.dart
│   └── ...
├── features/                          # Feature modules
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── manga_grid.dart
│   │       ├── manga_card.dart
│   │       ├── featured_carousel.dart
│   │       └── section_header.dart
│   ├── search/
│   │   ├── search_screen.dart
│   │   └── widgets/
│   │       ├── search_bar.dart
│   │       ├── filter_chips.dart
│   │       └── search_results.dart
│   ├── manga_detail/
│   │   ├── manga_detail_screen.dart
│   │   └── widgets/
│   │       ├── manga_header.dart
│   │       ├── chapter_list.dart
│   │       ├── comment_section.dart
│   │       └── rating_widget.dart
│   ├── reader/
│   │   ├── reader_screen.dart
│   │   └── widgets/
│   │       ├── page_viewer.dart       # Vertical scroll + page-flip modes
│   │       ├── reader_controls.dart
│   │       └── chapter_navigator.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── widgets/
│   ├── library/
│   │   ├── library_screen.dart        # Favorites + Reading History
│   │   └── widgets/
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── widgets/
│   ├── notifications/
│   │   ├── notifications_screen.dart
│   │   └── widgets/
│   ├── chatbot/
│   │   ├── chatbot_panel.dart
│   │   └── widgets/
│   ├── premium/
│   │   ├── subscription_screen.dart
│   │   ├── payment_screen.dart
│   │   └── widgets/
│   └── admin/
│       ├── admin_dashboard.dart
│       ├── user_management_screen.dart
│       ├── content_management_screen.dart
│       ├── moderation_screen.dart
│       ├── sync_dashboard_screen.dart
│       └── widgets/
└── shared/                            # Reusable widgets used across features
    ├── widgets/
    │   ├── manga_card.dart            # Standard manga card (cover + title + tags)
    │   ├── manga_grid.dart            # Responsive grid of manga cards
    │   ├── tag_chip.dart              # Genre/status tag pill
    │   ├── star_rating.dart           # 1-5 star rating display/input
    │   ├── loading_skeleton.dart      # Shimmer loading placeholders
    │   ├── error_view.dart            # Error state with retry
    │   ├── empty_state.dart           # Empty list/search state
    │   ├── user_avatar.dart           # Circular user avatar
    │   ├── app_shell.dart             # Sidebar + bottom nav scaffold
    │   └── responsive_builder.dart    # Mobile/tablet/desktop breakpoints
    └── dialogs/
        ├── confirm_dialog.dart
        └── report_dialog.dart
```

## Reusability Rules

### Widget Design

1. **Extract early, extract often.** If a widget subtree appears in 2+ places OR exceeds ~80 lines, extract it.
2. **Every shared widget goes in `shared/widgets/`.** Feature-specific widgets go in `features/<name>/widgets/`.
3. **Widgets must be stateless by default.** Use ConsumerWidget (Riverpod) only when reading providers. If a widget only takes data, use StatelessWidget.
4. **Parameterize, don't branch.** A `MangaCard` should accept `onTap`, `showRating`, `showTags` params — NOT have internal if-else for "home mode" vs "search mode".
5. **Composition over configuration.** Prefer building complex UI by composing small widgets rather than a mega-widget with 20 parameters.

### Responsive Design

```dart
// Use LayoutBuilder or MediaQuery, NOT separate widgets per platform
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  // Breakpoints (MangaDex-like)
  // mobile: < 768
  // tablet: 768 - 1024
  // desktop: > 1024
}

// Manga grid column count adapts:
// mobile: 2-3 columns
// tablet: 4 columns
// desktop: 5-6 columns
```

### Image Handling

```dart
// ALWAYS use CachedNetworkImage for remote images
CachedNetworkImage(
  imageUrl: manga.coverUrl,
  placeholder: (_, __) => const CoverSkeleton(),
  errorWidget: (_, __, ___) => const CoverPlaceholder(),
  fit: BoxFit.cover,
)

// Cover images: 2:3 aspect ratio
AspectRatio(
  aspectRatio: 2 / 3,
  child: CachedNetworkImage(...),
)
```

## Data Layer

### Models (freezed)

```dart
@freezed
class Manga with _$Manga {
  const factory Manga({
    required String id,
    required String title,
    required String? description,
    required String coverUrl,
    required List<String> tags,
    required MangaStatus status,
    required double averageRating,
    required int totalChapters,
    required String author,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}
```

### HTTP Client (Dio)

```dart
// Use Dio with interceptors for:
// - JWT token injection (Authorization header)
// - Token refresh on 401
// - Request/response logging (debug only)
// - Error transformation to typed exceptions
```

## Key Packages (required)

```yaml
dependencies:
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0
  go_router: ^14.0.0
  dio: ^5.7.0
  cached_network_image: ^3.4.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  google_fonts: ^6.2.0
  shared_preferences: ^2.3.0
  flutter_svg: ^2.0.0
  shimmer: ^3.0.0
  infinite_scroll_pagination: ^4.0.0
  gap: ^3.0.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.6.0
  flutter_lints: ^5.0.0
```

## Performance

- Use `const` constructors everywhere possible
- Use `ListView.builder` / `GridView.builder` for lists (never `Column(children: list.map(...))`)
- Preload next 2-3 manga page images in reader (FR-08 requirement)
- Use shimmer/skeleton loading states, never empty screens
- Images: use `CachedNetworkImage` with `memCacheWidth` to limit decode size
- Minimize widget rebuilds: granular providers, `select()` on Riverpod watches

## Accessibility

- All interactive elements must have tap targets >= 48x48
- Images need `semanticLabel`
- Support system font scaling
- Color contrast ratio >= 4.5:1 for text

## What NOT to Do

- Do NOT use `setState` for anything beyond trivial local animation state
- Do NOT create "god widgets" — screens with 500+ lines of build code
- Do NOT hardcode colors/sizes — always reference theme/constants
- Do NOT use `Navigator.push` — use GoRouter exclusively
- Do NOT put business logic in widgets — it belongs in providers/repositories
- Do NOT ignore loading/error states — every async operation needs all 3 states (loading, data, error)
- Do NOT modify anything in `REF/` — it's read-only reference code
