abstract class AppConstants {
  // App
  static const String appName = 'Manga Reader';
  static const String appVersion = '1.0.0';

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultMangaGridPageSize = 30;

  // Cover aspect ratio
  static const double coverAspectRatio = 2 / 3;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Reader
  static const int preloadPageCount = 3;
  static const int maxCachedPages = 10;

  // Image cache
  static const int imageCacheWidth = 800;
  static const int thumbnailCacheWidth = 400;
}
