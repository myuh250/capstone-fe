import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class ChapterManifest {
  const ChapterManifest({
    required this.chapterId,
    required this.mangaId,
    required this.mangaTitle,
    this.chapterNumber,
    this.chapterTitle,
    required this.totalPages,
    required this.imageUrls,
  });

  final String chapterId;
  final String mangaId;
  final String mangaTitle;
  final double? chapterNumber;
  final String? chapterTitle;
  final int totalPages;
  final List<String> imageUrls;

  factory ChapterManifest.fromJson(Map<String, dynamic> json) {
    return ChapterManifest(
      chapterId: json['chapterId'] as String,
      mangaId: json['mangaId'] as String,
      mangaTitle: json['mangaTitle'] as String? ?? '',
      chapterNumber: (json['chapterNumber'] as num?)?.toDouble(),
      chapterTitle: json['chapterTitle'] as String?,
      totalPages: json['totalPages'] as int? ?? 0,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class DownloadedChapter {
  const DownloadedChapter({
    required this.id,
    required this.chapterId,
    this.chapterNumber,
    this.chapterTitle,
    required this.mangaId,
    required this.mangaTitle,
    this.mangaCoverUrl,
    this.downloadedAt,
  });

  final int id;
  final String chapterId;
  final double? chapterNumber;
  final String? chapterTitle;
  final String mangaId;
  final String mangaTitle;
  final String? mangaCoverUrl;
  final DateTime? downloadedAt;

  factory DownloadedChapter.fromJson(Map<String, dynamic> json) {
    return DownloadedChapter(
      id: json['id'] as int,
      chapterId: json['chapterId'] as String,
      chapterNumber: (json['chapterNumber'] as num?)?.toDouble(),
      chapterTitle: json['chapterTitle'] as String?,
      mangaId: json['mangaId'] as String,
      mangaTitle: json['mangaTitle'] as String? ?? '',
      mangaCoverUrl: json['mangaCoverUrl'] as String?,
      downloadedAt: json['downloadedAt'] != null
          ? DateTime.tryParse(json['downloadedAt'] as String)
          : null,
    );
  }
}

class OfflineRepository {
  OfflineRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ChapterManifest> getManifest(String chapterId) async {
    final response =
        await _apiClient.get(ApiEndpoints.offlineManifest(chapterId));
    return ChapterManifest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DownloadedChapter> markDownloaded(String chapterId) async {
    final response =
        await _apiClient.post(ApiEndpoints.offlineMarkDownloaded(chapterId));
    return DownloadedChapter.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<DownloadedChapter>> getMyDownloads() async {
    final response = await _apiClient.get(ApiEndpoints.offlineMyDownloads);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DownloadedChapter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> removeDownload(String chapterId) async {
    await _apiClient.delete(ApiEndpoints.offlineRemove(chapterId));
  }
}
