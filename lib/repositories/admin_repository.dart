import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/user.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
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

class SyncConfig {
  const SyncConfig({
    required this.jobType,
    required this.cronExpression,
    required this.enabled,
    this.lastRunTime,
    this.lastRunStatus,
  });

  final String jobType;
  final String cronExpression;
  final bool enabled;
  final DateTime? lastRunTime;
  final String? lastRunStatus;

  factory SyncConfig.fromJson(Map<String, dynamic> json) {
    return SyncConfig(
      jobType: json['jobType'] as String,
      cronExpression: json['cronExpression'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      lastRunTime: json['lastRunTime'] != null
          ? DateTime.tryParse(json['lastRunTime'] as String)
          : null,
      lastRunStatus: json['lastRunStatus'] as String?,
    );
  }
}

class SyncDashboard {
  const SyncDashboard({
    required this.totalSyncs,
    required this.successCount,
    required this.failedCount,
    this.lastSyncTime,
    this.lastSyncStatus,
    required this.configs,
  });

  final int totalSyncs;
  final int successCount;
  final int failedCount;
  final DateTime? lastSyncTime;
  final String? lastSyncStatus;
  final List<SyncConfig> configs;

  factory SyncDashboard.fromJson(Map<String, dynamic> json) {
    final configsList = (json['configs'] as List<dynamic>?)
            ?.map((e) => SyncConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return SyncDashboard(
      totalSyncs: json['totalSyncs'] as int? ?? 0,
      successCount: json['successCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      lastSyncStatus: json['lastSyncStatus'] as String?,
      configs: configsList,
    );
  }
}

class SyncLog {
  const SyncLog({
    required this.id,
    required this.jobType,
    required this.status,
    this.summary,
    this.durationMs,
    this.startedAt,
    this.completedAt,
  });

  final int id;
  final String jobType;
  final String status;
  final String? summary;
  final int? durationMs;
  final DateTime? startedAt;
  final DateTime? completedAt;

  factory SyncLog.fromJson(Map<String, dynamic> json) {
    return SyncLog(
      id: json['id'] as int,
      jobType: json['jobType'] as String,
      status: json['status'] as String,
      summary: json['summary'] as String?,
      durationMs: json['durationMs'] as int?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}

class AiModerationResult {
  const AiModerationResult({
    required this.id,
    required this.commentId,
    this.commentContent,
    this.commentAuthor,
    required this.classification,
    required this.actionTaken,
    this.actionDescription,
    this.createdAt,
  });

  final int id;
  final int commentId;
  final String? commentContent;
  final String? commentAuthor;
  final String classification;
  final bool actionTaken;
  final String? actionDescription;
  final DateTime? createdAt;

  factory AiModerationResult.fromJson(Map<String, dynamic> json) {
    return AiModerationResult(
      id: json['id'] as int,
      commentId: json['commentId'] as int? ?? 0,
      commentContent: json['commentContent'] as String?,
      commentAuthor: json['commentAuthor'] as String?,
      classification: json['classification'] as String? ?? 'UNKNOWN',
      actionTaken: json['actionTaken'] as bool? ?? false,
      actionDescription: json['actionDescription'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class AiModerationStats {
  const AiModerationStats({
    required this.totalAnalyzed,
    required this.totalFlagged,
    required this.safeCount,
  });

  final int totalAnalyzed;
  final int totalFlagged;
  final int safeCount;

  factory AiModerationStats.fromJson(Map<String, dynamic> json) {
    return AiModerationStats(
      totalAnalyzed: json['totalAnalyzed'] as int? ?? 0,
      totalFlagged: json['totalFlagged'] as int? ?? 0,
      safeCount: json['safeCount'] as int? ?? 0,
    );
  }
}

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  // ─── User Management ───

  Future<List<User>> getUsers({
    String? query,
    String? role,
    bool? enabled,
    int page = 0,
    int size = 50,
  }) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (query != null && query.isNotEmpty) params['query'] = query;
    if (role != null) params['role'] = role;
    if (enabled != null) params['enabled'] = enabled;

    final response = await _apiClient.get(
      ApiEndpoints.adminUsers,
      queryParameters: params,
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<User> deactivateUser(String userId) async {
    final response = await _apiClient.put(
      ApiEndpoints.adminDeactivateUser(userId),
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> reactivateUser(String userId) async {
    final response = await _apiClient.put(
      ApiEndpoints.adminReactivateUser(userId),
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Manga Management ───

  Future<Map<String, dynamic>> createManga({
    required String title,
    required String description,
    required String status,
    String? coverUrl,
    List<String>? genreNames,
    List<String>? authorNames,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status,
    };
    if (coverUrl != null) data['coverUrl'] = coverUrl;
    if (genreNames != null) data['genreNames'] = genreNames;
    if (authorNames != null) data['authorNames'] = authorNames;

    final response = await _apiClient.post(ApiEndpoints.adminMangas, data: data);
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateManga({
    required String mangaId,
    String? title,
    String? description,
    String? status,
    String? coverUrl,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;
    if (coverUrl != null) data['coverUrl'] = coverUrl;

    final response = await _apiClient.put(
      ApiEndpoints.adminMangaById(mangaId),
      data: data,
    );
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  Future<void> deleteManga(String mangaId) async {
    await _apiClient.delete(ApiEndpoints.adminMangaDelete(mangaId));
  }

  // ─── Chapter Management ───

  Future<List<Map<String, dynamic>>> getChaptersByManga(String mangaId) async {
    final response = await _apiClient.get(ApiEndpoints.chaptersByManga(mangaId));
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createChapter({
    required String mangaId,
    required double chapterNumber,
    String? title,
    List<String>? imageUrls,
  }) async {
    final data = <String, dynamic>{
      'mangaId': mangaId,
      'chapterNumber': chapterNumber,
    };
    if (title != null && title.isNotEmpty) data['title'] = title;
    if (imageUrls != null && imageUrls.isNotEmpty) data['imageUrls'] = imageUrls;

    final response = await _apiClient.post(ApiEndpoints.chapters, data: data);
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  Future<void> deleteChapter(String chapterId) async {
    await _apiClient.delete(ApiEndpoints.chapterById(chapterId));
  }

  // ─── Sync Dashboard ───

  Future<SyncDashboard> getSyncDashboard() async {
    final response = await _apiClient.get(ApiEndpoints.adminSyncDashboard);
    return SyncDashboard.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SyncLog>> getSyncLogs({String? jobType, int page = 0, int size = 20}) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (jobType != null) params['jobType'] = jobType;

    final response = await _apiClient.get(
      ApiEndpoints.adminSyncLogs,
      queryParameters: params,
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) => SyncLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SyncConfig> updateSyncConfig({
    required String jobType,
    required String cronExpression,
    required bool enabled,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.adminSyncConfig,
      data: {
        'jobType': jobType,
        'cronExpression': cronExpression,
        'enabled': enabled,
      },
    );
    return SyncConfig.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SyncLog> triggerSync(String jobType, {int? limit}) async {
    final params = <String, dynamic>{};
    if (limit != null) params['limit'] = limit;

    final response = await _apiClient.post(
      ApiEndpoints.adminSyncTrigger(jobType),
      queryParameters: params.isNotEmpty ? params : null,
    );
    return SyncLog.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── AI Moderation ───

  Future<List<AiModerationResult>> getAiModerationResults({
    bool flaggedOnly = false,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminAiModerationResults,
      queryParameters: {
        'flaggedOnly': flaggedOnly,
        'page': page,
        'size': size,
      },
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) => AiModerationResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AiModerationStats> getAiModerationStats() async {
    final response = await _apiClient.get(ApiEndpoints.adminAiModerationStats);
    return AiModerationStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AiModerationResult>> getAiModerationPending({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminAiModerationPending,
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) => AiModerationResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveAiFlag(int resultId) async {
    await _apiClient.post(ApiEndpoints.adminAiModerationApprove(resultId));
  }

  Future<void> removeAiFlaggedContent(int resultId) async {
    await _apiClient.post(ApiEndpoints.adminAiModerationRemove(resultId));
  }

  // ─── Moderation Actions ───

  Future<void> performModerationAction({
    required String action,
    String? targetUserId,
    String? targetCommentId,
    String? note,
  }) async {
    final data = <String, dynamic>{'action': action};
    if (targetUserId != null) data['targetUserId'] = int.tryParse(targetUserId) ?? targetUserId;
    if (targetCommentId != null) data['targetCommentId'] = int.tryParse(targetCommentId) ?? targetCommentId;
    if (note != null) data['note'] = note;

    await _apiClient.post(ApiEndpoints.moderationActions, data: data);
  }

  // ─── Dashboard Stats ───

  Future<AdminDashboardStats> getDashboardStats() async {
    final response = await _apiClient.get(ApiEndpoints.adminStats);
    final data = response.data as Map<String, dynamic>;
    return AdminDashboardStats(
      totalUsers: data['totalUsers'] as int? ?? 0,
      totalManga: data['totalManga'] as int? ?? 0,
      totalChapters: data['totalChapters'] as int? ?? 0,
      totalReports: data['pendingReports'] as int? ?? 0,
      newUsersToday: 0,
      activeReaders: 0,
    );
  }
}
