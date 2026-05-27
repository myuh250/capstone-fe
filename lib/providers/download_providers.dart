import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../repositories/offline_repository.dart';
import '../services/chapter_storage_service.dart';

enum DownloadStatus { queued, downloading, paused, completed, failed }

class DownloadItem {
  const DownloadItem({
    required this.mangaId,
    required this.mangaTitle,
    required this.coverUrl,
    required this.chapterId,
    required this.chapterTitle,
    required this.status,
    this.progress = 0.0,
    this.totalPages = 0,
    this.downloadedPages = 0,
  });

  final String mangaId;
  final String mangaTitle;
  final String coverUrl;
  final String chapterId;
  final String chapterTitle;
  final DownloadStatus status;
  final double progress;
  final int totalPages;
  final int downloadedPages;

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    int? downloadedPages,
    int? totalPages,
  }) {
    return DownloadItem(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverUrl: coverUrl,
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalPages: totalPages ?? this.totalPages,
      downloadedPages: downloadedPages ?? this.downloadedPages,
    );
  }

  String get id => '${mangaId}_$chapterId';
}

// --- Providers ---

final offlineRepositoryProvider = Provider<OfflineRepository>((ref) {
  return OfflineRepository(ref.watch(apiClientProvider));
});

final chapterStorageServiceProvider = Provider<ChapterStorageService>((ref) {
  return ChapterStorageService(Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  )));
});

final myDownloadsProvider = FutureProvider<List<DownloadedChapter>>((ref) {
  return ref.watch(offlineRepositoryProvider).getMyDownloads();
});

final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, List<DownloadItem>>(
  (ref) => DownloadsNotifier(ref),
);

final isChapterDownloadedProvider =
    Provider.family<bool, String>((ref, chapterId) {
  final downloads = ref.watch(downloadsProvider);
  return downloads
      .any((d) => d.chapterId == chapterId && d.status == DownloadStatus.completed);
});

final storageUsedBytesProvider = Provider<int>((ref) {
  final downloads = ref.watch(downloadsProvider);
  return downloads
      .where((d) => d.status == DownloadStatus.completed)
      .fold(0, (sum, d) => sum + d.totalPages * 400 * 1024);
});

class DownloadsNotifier extends StateNotifier<List<DownloadItem>> {
  DownloadsNotifier(this._ref) : super([]) {
    _loadFromServer();
  }

  final Ref _ref;

  Future<void> _loadFromServer() async {
    try {
      final repo = _ref.read(offlineRepositoryProvider);
      final serverDownloads = await repo.getMyDownloads();
      final serverItems = serverDownloads
          .map((sd) => DownloadItem(
                mangaId: sd.mangaId,
                mangaTitle: sd.mangaTitle,
                coverUrl: sd.mangaCoverUrl ?? '',
                chapterId: sd.chapterId,
                chapterTitle: sd.chapterTitle ?? 'Ch.${sd.chapterNumber?.toInt() ?? 0}',
                status: DownloadStatus.completed,
                progress: 1.0,
              ))
          .toList();
      state = serverItems;
    } catch (_) {}
  }

  Future<void> startDownload({
    required String mangaId,
    required String mangaTitle,
    required String coverUrl,
    required String chapterId,
    required String chapterTitle,
  }) async {
    if (state.any((d) => d.chapterId == chapterId)) return;

    state = [
      ...state,
      DownloadItem(
        mangaId: mangaId,
        mangaTitle: mangaTitle,
        coverUrl: coverUrl,
        chapterId: chapterId,
        chapterTitle: chapterTitle,
        status: DownloadStatus.queued,
      ),
    ];

    try {
      final repo = _ref.read(offlineRepositoryProvider);
      final storage = _ref.read(chapterStorageServiceProvider);
      final manifest = await repo.getManifest(chapterId);

      _updateItem(chapterId, (d) => d.copyWith(
        status: DownloadStatus.downloading,
        totalPages: manifest.totalPages,
      ));

      final success = await storage.downloadChapter(
        chapterId,
        manifest.imageUrls,
        onProgress: (downloaded, total) {
          _updateItem(chapterId, (d) => d.copyWith(
            progress: downloaded / total,
            downloadedPages: downloaded,
          ));
        },
        isCancelled: () {
          final current = state.where((d) => d.chapterId == chapterId).firstOrNull;
          return current == null || current.status == DownloadStatus.paused;
        },
      );

      if (!success) return;

      await repo.markDownloaded(chapterId);

      _updateItem(chapterId, (d) => d.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        downloadedPages: manifest.totalPages,
      ));
    } catch (e) {
      _updateItem(chapterId, (d) => d.copyWith(status: DownloadStatus.failed));
    }
  }

  void pauseDownload(String id) {
    state = state.map((d) {
      if (d.id == id && d.status == DownloadStatus.downloading) {
        return d.copyWith(status: DownloadStatus.paused);
      }
      return d;
    }).toList();
  }

  void resumeDownload(String id) {
    final item = state.firstWhere((d) => d.id == id, orElse: () => state.first);
    if (item.status != DownloadStatus.paused) return;
    // Remove old entry and restart
    state = state.where((d) => d.id != id).toList();
    startDownload(
      mangaId: item.mangaId,
      mangaTitle: item.mangaTitle,
      coverUrl: item.coverUrl,
      chapterId: item.chapterId,
      chapterTitle: item.chapterTitle,
    );
  }

  Future<void> removeDownload(String id) async {
    final item = state.firstWhere((d) => d.id == id, orElse: () => state.first);
    try {
      final repo = _ref.read(offlineRepositoryProvider);
      await repo.removeDownload(item.chapterId);
    } catch (_) {}

    final storage = _ref.read(chapterStorageServiceProvider);
    await storage.deleteChapter(item.chapterId);

    state = state.where((d) => d.id != id).toList();
  }

  bool isDownloaded(String chapterId) {
    return state.any(
        (d) => d.chapterId == chapterId && d.status == DownloadStatus.completed);
  }

  void _updateItem(String chapterId, DownloadItem Function(DownloadItem) updater) {
    state = state.map((d) => d.chapterId == chapterId ? updater(d) : d).toList();
  }
}
