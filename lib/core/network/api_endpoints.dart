import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiEndpoints {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:9000/api';
  static String get wsUrl => dotenv.env['WS_URL'] ?? 'ws://localhost:9000/ws';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerOtp = '/auth/register-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String googleLogin = '/auth/google';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // User
  static const String profile = '/users/me';
  static const String updateProfile = '/users/me/profile';
  static const String changePassword = '/users/me/change-password';

  // Manga
  static const String mangas = '/mangas';
  static String mangaById(String id) => '/mangas/$id';
  static String mangaBySlug(String slug) => '/mangas/by-slug/$slug';
  static const String mangasTrending = '/mangas/trending';
  static const String mangasRecent = '/mangas/recent';

  // Chapter
  static const String chapters = '/chapters';
  static String chaptersByManga(String mangaId) => '/chapters/manga/$mangaId';
  static String chapterById(String id) => '/chapters/$id';
  static String chapterImages(String id) => '/chapters/$id/images';

  // Search & Filter (uses /mangas with query params)
  static const String search = '/mangas';
  static const String genres = '/genres';

  // Authors
  static const String authors = '/authors';
  static String authorById(String id) => '/authors/$id';
  static const String authorsSearch = '/authors/search';

  // Library (favorites/bookmarks) — resolved from JWT on BE, no userId in path
  static const String libraryMe = '/library/me';
  static String libraryMeByStatus(String status) => '/library/me/status/$status';
  static const String libraryAdd = '/library';
  static String libraryUpdate(String id) => '/library/$id';
  static String libraryDelete(String id) => '/library/$id';

  // Reading History — resolved from JWT on BE, no userId in path
  static const String historyMe = '/history/user/me';
  static String historyMeByManga(String mangaId) => '/history/user/me/manga/$mangaId';
  static const String historyProgress = '/history/progress';
  static String historyProgressByManga(String mangaId) =>
      '/history/progress/manga/$mangaId';
  static String historyDelete(String id) => '/history/$id';

  // Ratings
  static String userRating(String userId, String mangaId) =>
      '/ratings/user/$userId/manga/$mangaId';
  static String mangaAverageRating(String mangaId) =>
      '/ratings/manga/$mangaId/average';
  static const String ratingsCreate = '/ratings';
  static String ratingsDelete(String id) => '/ratings/$id';

  // Comments
  static String commentsByManga(String mangaId) => '/comments/manga/$mangaId';
  static const String commentsCreate = '/comments';
  static String commentById(String id) => '/comments/$id';
  static String commentUpdate(String id) => '/comments/$id';
  static String commentDelete(String id) => '/comments/$id';
  static const String mentionSearch = '/comments/mentions/search';

  // Recommendations
  static const String recommendations = '/recommendations';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationPreferences = '/notifications/preferences';
  static const String notificationDeviceToken = '/notifications/device-token';
  static String notificationDeviceTokenDelete(String deviceId) =>
      '/notifications/device-token/$deviceId';

  // Premium / Subscriptions
  static const String subscriptions = '/subscriptions';

  // Reports
  static const String reports = '/reports';
  static String reportReview(String reportId) => '/reports/$reportId/review';

  // Moderation (Admin)
  static const String moderationActions = '/moderation/actions';
  static const String moderationLogs = '/moderation/logs';
  static String moderationLogsByUser(String userId) =>
      '/moderation/logs/user/$userId';

  // Admin - Users
  static const String adminUsers = '/users';
  static String adminUserById(String id) => '/users/$id';
  static String adminDeactivateUser(String id) => '/users/$id/deactivate';
  static String adminReactivateUser(String id) => '/users/$id/reactivate';

  // Admin - Manga
  static const String adminMangas = '/mangas';
  static String adminMangaById(String id) => '/mangas/$id';
  static String adminMangaDelete(String id) => '/mangas/$id';

  // Admin - Upload
  static const String uploadCover = '/upload/cover';
  static const String uploadPages = '/upload/pages';

  // Admin - AI Moderation
  static const String adminAiModerationResults =
      '/admin/ai-moderation/results';
  static const String adminAiModerationPending =
      '/admin/ai-moderation/pending';
  static const String adminAiModerationStats = '/admin/ai-moderation/stats';
  static String adminAiModerationApprove(int id) =>
      '/admin/ai-moderation/$id/approve';
  static String adminAiModerationRemove(int id) =>
      '/admin/ai-moderation/$id/remove';

  // Admin - Stats
  static const String adminStats = '/admin/stats';

  // Admin - Sync Dashboard
  static const String adminSyncDashboard = '/admin/sync/dashboard';
  static const String adminSyncLogs = '/admin/sync/logs';
  static const String adminSyncConfig = '/admin/sync/config';
  static String adminSyncTrigger(String jobType) =>
      '/admin/sync/trigger/$jobType';

  // Admin - Payments
  static const String adminPayments = '/admin/payments';

  // Admin - Embedding
  static const String adminEmbeddingBackfill = '/ai/embeddings/backfill';

  // AI Chatbot
  static const String aiChat = '/ai/chat';
  static const String aiAdminChat = '/ai/admin-chat';
  static const String aiSync = '/ai/sync';
  static String aiSyncJob(String jobId) => '/ai/sync/$jobId';

  // Image Proxy
  static const String proxyImage = '/proxy/image';

  // Offline (Premium)
  static String offlineManifest(String chapterId) =>
      '/offline/chapters/$chapterId/manifest';
  static String offlineMarkDownloaded(String chapterId) =>
      '/offline/chapters/$chapterId';
  static const String offlineMyDownloads = '/offline/my-downloads';
  static String offlineRemove(String chapterId) =>
      '/offline/chapters/$chapterId';

  // Admin - Chapter early access
  static String chapterEarlyAccess(String id) => '/chapters/$id/early-access';
}
