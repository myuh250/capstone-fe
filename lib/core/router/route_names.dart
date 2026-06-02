abstract class RouteNames {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify';

  // Main
  static const String home = '/';
  static const String browse = '/browse';
  static const String search = '/search';
  static const String library = '/library';
  static const String profile = '/profile';

  // Manga — slug-based clean URLs
  static String mangaDetail(String slug) => '/manga/$slug';
  static String mangaDetailComments(String slug) =>
      '/manga/$slug?scrollTo=comments';

  static String reader(String mangaSlug, double chapterNumber, {String? cid}) {
    final chNum = chapterNumber == chapterNumber.truncateToDouble()
        ? 'chapter-${chapterNumber.toInt()}'
        : 'chapter-$chapterNumber';
    final path = '/manga/$mangaSlug/$chNum';
    if (cid != null) return '$path?cid=$cid';
    return path;
  }

  /// Derive a URL slug from a title (client-side fallback when slug is not available)
  static String titleToSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  // Profile
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String settings = '/profile/settings';
  static const String readingHistory = '/library/history';
  static const String favorites = '/library/favorites';

  // Premium
  static const String subscription = '/premium';
  static const String payment = '/premium/payment';
  static const String paymentResult = '/premium/payment/result';
  static const String paymentHistory = '/profile/payments';

  // Notifications
  static const String notifications = '/notifications';

  // Downloads
  static const String downloads = '/library/downloads';

  // Premium (alias)
  static const String premium = '/premium';

  // Admin
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static String adminUserDetail(String id) => '/admin/users/$id';
  static const String adminContent = '/admin/content';
  static String adminMangaEdit(String id) => '/admin/content/manga/$id/edit';
  static String adminMangaChapters(String id) => '/admin/content/manga/$id/chapters';
  static const String adminReports = '/admin/reports';
  static const String adminModeration = '/admin/moderation';
  static const String adminAiSync = '/admin/ai-sync';
  static const String adminSync = '/admin/sync';
  static const String adminPayments = '/admin/payments';
  static String adminReportDetail(String id) => '/admin/reports/$id';
}
