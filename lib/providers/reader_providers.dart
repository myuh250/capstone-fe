import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chapter.dart';
import '../models/chapter_page.dart';
import '../repositories/chapter_repository.dart';

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return FakeChapterRepository();
});

final chapterPagesProvider =
    FutureProvider.family<List<ChapterPage>, String>((ref, chapterId) {
  return ref.watch(chapterRepositoryProvider).getPages(chapterId);
});

class AdjacentChaptersParams {
  const AdjacentChaptersParams({
    required this.mangaId,
    required this.chapterNumber,
  });

  final String mangaId;
  final double chapterNumber;

  @override
  bool operator ==(Object other) =>
      other is AdjacentChaptersParams &&
      other.mangaId == mangaId &&
      other.chapterNumber == chapterNumber;

  @override
  int get hashCode => Object.hash(mangaId, chapterNumber);
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
  );
  final next = await repo.getNextChapter(
    params.mangaId,
    params.chapterNumber,
  );
  return AdjacentChapters(previous: prev, next: next);
});

class ReaderState {
  const ReaderState({
    this.currentPage = 0,
    this.isOverlayVisible = true,
    this.isVerticalMode = true,
  });

  final int currentPage;
  final bool isOverlayVisible;
  final bool isVerticalMode;

  ReaderState copyWith({
    int? currentPage,
    bool? isOverlayVisible,
    bool? isVerticalMode,
  }) {
    return ReaderState(
      currentPage: currentPage ?? this.currentPage,
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
      isVerticalMode: isVerticalMode ?? this.isVerticalMode,
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
