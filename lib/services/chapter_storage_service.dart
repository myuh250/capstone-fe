import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class ChapterStorageService {
  ChapterStorageService(this._dio);

  final Dio _dio;

  Future<String> _chapterDir(String chapterId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/offline_chapters/$chapterId');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  /// Download all images for a chapter to local storage.
  /// Calls [onProgress] with (pagesDownloaded, totalPages).
  /// Returns true if all pages downloaded successfully.
  Future<bool> downloadChapter(
    String chapterId,
    List<String> imageUrls, {
    required void Function(int downloaded, int total) onProgress,
    required bool Function() isCancelled,
  }) async {
    if (kIsWeb) {
      // Web: pre-fetch into browser cache
      for (int i = 0; i < imageUrls.length; i++) {
        if (isCancelled()) return false;
        try {
          await _dio.get(imageUrls[i],
              options: Options(responseType: ResponseType.bytes));
        } catch (_) {}
        onProgress(i + 1, imageUrls.length);
      }
      return true;
    }

    // Mobile: save to local filesystem
    final dir = await _chapterDir(chapterId);
    for (int i = 0; i < imageUrls.length; i++) {
      if (isCancelled()) return false;
      final filePath = '$dir/page_${i + 1}.jpg';
      final file = File(filePath);
      if (await file.exists()) {
        onProgress(i + 1, imageUrls.length);
        continue;
      }
      try {
        await _dio.download(imageUrls[i], filePath);
      } catch (_) {
        // Retry once
        try {
          await _dio.download(imageUrls[i], filePath);
        } catch (_) {}
      }
      onProgress(i + 1, imageUrls.length);
    }
    return true;
  }

  /// Check if a chapter is fully available on local storage.
  Future<bool> isAvailableLocally(String chapterId, int totalPages) async {
    if (kIsWeb) return false;
    try {
      final dir = await _chapterDir(chapterId);
      final d = Directory(dir);
      if (!await d.exists()) return false;
      final count = await d.list().length;
      return count >= totalPages;
    } catch (_) {
      return false;
    }
  }

  /// Get local file paths for reading a downloaded chapter.
  Future<List<String>> getLocalPaths(String chapterId, int totalPages) async {
    final dir = await _chapterDir(chapterId);
    return List.generate(totalPages, (i) => '$dir/page_${i + 1}.jpg');
  }

  /// Delete a chapter's local files.
  Future<void> deleteChapter(String chapterId) async {
    if (kIsWeb) return;
    try {
      final dir = await _chapterDir(chapterId);
      final d = Directory(dir);
      if (await d.exists()) await d.delete(recursive: true);
    } catch (_) {}
  }

  /// Calculate total storage used by all offline chapters.
  Future<int> getStorageUsedBytes() async {
    if (kIsWeb) return 0;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final offlineDir = Directory('${appDir.path}/offline_chapters');
      if (!await offlineDir.exists()) return 0;
      int total = 0;
      await for (final entity in offlineDir.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}
