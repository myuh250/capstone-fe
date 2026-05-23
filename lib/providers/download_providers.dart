import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.fileSizeBytes = 0,
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
  final int fileSizeBytes;

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    int? downloadedPages,
  }) {
    return DownloadItem(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverUrl: coverUrl,
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalPages: totalPages,
      downloadedPages: downloadedPages ?? this.downloadedPages,
      fileSizeBytes: fileSizeBytes,
    );
  }

  String get id => '${mangaId}_$chapterId';
}

class DownloadsNotifier extends StateNotifier<List<DownloadItem>> {
  DownloadsNotifier() : super(_fakeDownloads);

  static const _coverUrl =
      'https://uploads.mangadex.org/covers/a1c7c817-4e59-43b7-9365-09675a149a6f/1a5a20b4-05d9-4b77-9f85-7be7f21dc490.jpg';

  static final List<DownloadItem> _fakeDownloads = [
    DownloadItem(
      mangaId: '1',
      mangaTitle: 'One Piece',
      coverUrl: _coverUrl,
      chapterId: '1_ch_1',
      chapterTitle: 'Chapter 1 — Romance Dawn',
      status: DownloadStatus.completed,
      progress: 1.0,
      totalPages: 53,
      downloadedPages: 53,
      fileSizeBytes: 18 * 1024 * 1024,
    ),
    DownloadItem(
      mangaId: '1',
      mangaTitle: 'One Piece',
      coverUrl: _coverUrl,
      chapterId: '1_ch_2',
      chapterTitle: 'Chapter 2',
      status: DownloadStatus.completed,
      progress: 1.0,
      totalPages: 48,
      downloadedPages: 48,
      fileSizeBytes: 15 * 1024 * 1024,
    ),
    DownloadItem(
      mangaId: '12',
      mangaTitle: 'Chainsaw Man',
      coverUrl: _coverUrl,
      chapterId: '12_ch_1',
      chapterTitle: 'Chapter 1 — Chainsaw Man',
      status: DownloadStatus.downloading,
      progress: 0.6,
      totalPages: 40,
      downloadedPages: 24,
      fileSizeBytes: 12 * 1024 * 1024,
    ),
  ];

  void addDownload(DownloadItem item) {
    if (!state.any((d) => d.id == item.id)) {
      state = [...state, item];
    }
  }

  void removeDownload(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void pauseDownload(String id) {
    state = state
        .map((d) => d.id == id
            ? d.copyWith(status: DownloadStatus.paused)
            : d)
        .toList();
  }

  void resumeDownload(String id) {
    state = state
        .map((d) => d.id == id
            ? d.copyWith(status: DownloadStatus.downloading)
            : d)
        .toList();
  }

  bool isDownloaded(String chapterId) {
    return state.any((d) =>
        d.chapterId == chapterId &&
        d.status == DownloadStatus.completed);
  }
}

final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, List<DownloadItem>>(
  (ref) => DownloadsNotifier(),
);

final storageUsedBytesProvider = Provider<int>((ref) {
  final downloads = ref.watch(downloadsProvider);
  return downloads
      .where((d) => d.status == DownloadStatus.completed)
      .fold(0, (sum, d) => sum + d.fileSizeBytes);
});
