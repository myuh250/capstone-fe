import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../features/reader/widgets/reader_settings_panel.dart';
import '../models/chapter.dart';
import '../models/chapter_page.dart';
import '../models/manga.dart';
import '../repositories/chapter_repository.dart';
import 'manga_providers.dart';

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return RealChapterRepository(ref.watch(apiClientProvider));
});

class ReaderParams {
  const ReaderParams({
    required this.mangaSlug,
    required this.chapterNumber,
    this.chapterId,
  });
  final String mangaSlug;
  final double chapterNumber;
  final String? chapterId;

  @override
  bool operator ==(Object other) =>
      other is ReaderParams &&
      other.mangaSlug == mangaSlug &&
      other.chapterNumber == chapterNumber &&
      other.chapterId == chapterId;

  @override
  int get hashCode => Object.hash(mangaSlug, chapterNumber, chapterId);
}

class ResolvedReader {
  const ResolvedReader({required this.manga, required this.chapter});
  final Manga manga;
  final Chapter chapter;
}

final resolvedReaderProvider =
    FutureProvider.family<ResolvedReader, ReaderParams>((ref, params) async {
  final manga = await ref.watch(mangaBySlugProvider(params.mangaSlug).future);
  final repo = ref.watch(mangaRepositoryProvider);
  final chapters = await repo.getChapters(manga.id);

  Chapter chapter;
  if (params.chapterId != null) {
    chapter = chapters.firstWhere(
      (c) => c.id == params.chapterId,
      orElse: () => chapters.firstWhere(
        (c) => c.number == params.chapterNumber,
        orElse: () => chapters.first,
      ),
    );
  } else {
    chapter = chapters.firstWhere(
      (c) => c.number == params.chapterNumber,
      orElse: () => chapters.first,
    );
  }
  return ResolvedReader(manga: manga, chapter: chapter);
});

final chapterPagesProvider =
    FutureProvider.family<List<ChapterPage>, String>((ref, chapterId) {
  return ref.watch(chapterRepositoryProvider).getPages(chapterId);
});

class AdjacentChaptersParams {
  const AdjacentChaptersParams({
    required this.mangaId,
    required this.chapterNumber,
    required this.chapterId,
  });

  final String mangaId;
  final double chapterNumber;
  final String chapterId;

  @override
  bool operator ==(Object other) =>
      other is AdjacentChaptersParams &&
      other.mangaId == mangaId &&
      other.chapterNumber == chapterNumber &&
      other.chapterId == chapterId;

  @override
  int get hashCode => Object.hash(mangaId, chapterNumber, chapterId);
}

class AdjacentChapters {
  const AdjacentChapters({this.previous, this.next});

  final Chapter? previous;
  final Chapter? next;
}

final adjacentChaptersProvider = FutureProvider.family<AdjacentChapters,
    AdjacentChaptersParams>((ref, params) async {
  final repo = ref.watch(chapterRepositoryProvider);
  final prev = await repo.getPreviousChapter(
    params.mangaId,
    params.chapterNumber,
    currentChapterId: params.chapterId,
  );
  final next = await repo.getNextChapter(
    params.mangaId,
    params.chapterNumber,
    currentChapterId: params.chapterId,
  );
  return AdjacentChapters(previous: prev, next: next);
});

class ReaderState {
  const ReaderState({
    this.currentPage = 0,
    this.isOverlayVisible = true,
    this.isVerticalMode = true,
    this.brightness = 1.0,
    this.readerTheme = ReaderTheme.dark,
    this.autoNextChapter = false,
  });

  final int currentPage;
  final bool isOverlayVisible;
  final bool isVerticalMode;
  final double brightness;
  final ReaderTheme readerTheme;
  final bool autoNextChapter;

  ReaderState copyWith({
    int? currentPage,
    bool? isOverlayVisible,
    bool? isVerticalMode,
    double? brightness,
    ReaderTheme? readerTheme,
    bool? autoNextChapter,
  }) {
    return ReaderState(
      currentPage: currentPage ?? this.currentPage,
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
      isVerticalMode: isVerticalMode ?? this.isVerticalMode,
      brightness: brightness ?? this.brightness,
      readerTheme: readerTheme ?? this.readerTheme,
      autoNextChapter: autoNextChapter ?? this.autoNextChapter,
    );
  }
}

class ReaderNotifier extends StateNotifier<ReaderState> {
  ReaderNotifier() : super(const ReaderState());

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void toggleOverlay() {
    state = state.copyWith(isOverlayVisible: !state.isOverlayVisible);
  }

  void toggleReadingMode() {
    state = state.copyWith(isVerticalMode: !state.isVerticalMode);
  }

  void setBrightness(double value) {
    state = state.copyWith(brightness: value);
  }

  void setTheme(ReaderTheme theme) {
    state = state.copyWith(readerTheme: theme);
  }

  void setAutoNextChapter(bool value) {
    state = state.copyWith(autoNextChapter: value);
  }
}

class ReaderKey {
  const ReaderKey({required this.mangaId, required this.chapterId});

  final String mangaId;
  final String chapterId;

  @override
  bool operator ==(Object other) =>
      other is ReaderKey &&
      other.mangaId == mangaId &&
      other.chapterId == chapterId;

  @override
  int get hashCode => Object.hash(mangaId, chapterId);
}

final readerProvider =
    StateNotifierProvider.family<ReaderNotifier, ReaderState, ReaderKey>(
  (ref, key) => ReaderNotifier(),
);
