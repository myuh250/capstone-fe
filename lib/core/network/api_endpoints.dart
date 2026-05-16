abstract class ApiEndpoints {
  // Base URL — replace with actual backend URL
  static const String baseUrl = 'http://localhost:8080/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User
  static const String profile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String changePassword = '/users/me/password';
  static const String deleteAccount = '/users/me';

  // Manga
  static const String manga = '/manga';
  static String mangaById(String id) => '/manga/$id';
  static String mangaChapters(String id) => '/manga/$id/chapters';
  static String mangaRelated(String id) => '/manga/$id/related';

  // Chapter
  static String chapterById(String id) => '/chapters/$id';
  static String chapterPages(String id) => '/chapters/$id/pages';

  // Search
  static const String search = '/manga/search';
  static const String genres = '/genres';

  // Favorites
  static const String favorites = '/users/me/favorites';
  static String addFavorite(String mangaId) => '/users/me/favorites/$mangaId';
  static String removeFavorite(String mangaId) =>
      '/users/me/favorites/$mangaId';

  // Reading History
  static const String readingHistory = '/users/me/reading-history';
  static String saveProgress(String chapterId) =>
      '/chapters/$chapterId/progress';

  // Ratings
  static String rateManga(String mangaId) => '/manga/$mangaId/ratings';
  static String getUserRating(String mangaId) =>
      '/manga/$mangaId/ratings/me';

  // Comments
  static String mangaComments(String mangaId) => '/manga/$mangaId/comments';
  static String addComment(String mangaId) => '/manga/$mangaId/comments';
  static String deleteComment(String commentId) => '/comments/$commentId';

  // Recommendations
  static const String recommendations = '/users/me/recommendations';

  // Notifications
  static const String notifications = '/users/me/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // Premium / Subscriptions
  static const String subscriptions = '/subscriptions';

  // Admin
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';
  static String adminBanUser(String id) => '/admin/users/$id/ban';
  static String adminUnbanUser(String id) => '/admin/users/$id/unban';
  static const String adminManga = '/admin/manga';
  static String adminMangaById(String id) => '/admin/manga/$id';
  static const String adminReports = '/admin/reports';
  static String adminReportById(String id) => '/admin/reports/$id';
  static const String adminStats = '/admin/stats';

  // Chatbot
  static const String chatbotMessage = '/chatbot/message';
}
