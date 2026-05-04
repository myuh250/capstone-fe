abstract class RouteNames {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify';

  // Main
  static const String home = '/';
  static const String search = '/search';
  static const String library = '/library';
  static const String profile = '/profile';

  // Manga
  static String mangaDetail(String id) => '/manga/$id';
  static String reader(String mangaId, String chapterId) =>
      '/manga/$mangaId/chapter/$chapterId';

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

  // Admin
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminContent = '/admin/content';
  static String adminMangaEdit(String id) => '/admin/content/manga/$id/edit';
  static const String adminReports = '/admin/reports';
  static const String adminModeration = '/admin/moderation';
}
