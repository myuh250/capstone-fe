import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../providers/manga_providers.dart';
import '../../providers/reader_providers.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/page_viewer.dart';
import 'widgets/reader_app_bar.dart';
import 'widgets/reader_bottom_bar.dart';
import 'widgets/reader_settings_panel.dart';

const _progressSaveDebounceMs = 3000;

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({
    super.key,
    required this.mangaSlug,
    required this.chapterSlug,
    this.chapterId,
  });

  final String mangaSlug;
  final String chapterSlug;
  final String? chapterId;

  double get _chapterNumber {
    final match = RegExp(r'chapter-(.+)').firstMatch(chapterSlug);
    if (match != null) return double.tryParse(match.group(1)!) ?? 1.0;
    return 1.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ReaderParams(
      mangaSlug: mangaSlug,
      chapterNumber: _chapterNumber,
      chapterId: chapterId,
    );
    final resolvedAsync = ref.watch(resolvedReaderProvider(params));

    return resolvedAsync.when(
      data: (resolved) => _ReaderContent(
        manga: resolved.manga,
        chapter: resolved.chapter,
        mangaSlug: mangaSlug,
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: ErrorView(
          message: 'Failed to load chapter.',
          onRetry: () => ref.invalidate(resolvedReaderProvider(params)),
        ),
      ),
    );
  }
}

class _ReaderContent extends ConsumerStatefulWidget {
  const _ReaderContent({
    required this.manga,
    required this.chapter,
    required this.mangaSlug,
  });

  final Manga manga;
  final Chapter chapter;
  final String mangaSlug;

  @override
  ConsumerState<_ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends ConsumerState<_ReaderContent> {
  int _lastSavedPage = 0;
  DateTime _lastSaveTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool _initialProgressSaved = false;

  void _onPageChanged(int page) {
    final readerKey = ReaderKey(mangaId: widget.manga.id, chapterId: widget.chapter.id);
    ref.read(readerProvider(readerKey).notifier).setPage(page);
    _saveProgressDebounced(page);
  }

  void _saveProgressDebounced(int page) {
    final now = DateTime.now();
    if (page == _lastSavedPage) return;
    if (now.difference(_lastSaveTime).inMilliseconds < _progressSaveDebounceMs) return;
    _lastSavedPage = page;
    _lastSaveTime = now;
    _saveProgress(page);
  }

  void _saveProgress(int page) {
    final pageToSave = page < 1 ? 1 : page;
    ref.read(chapterRepositoryProvider).saveReadingProgress(
      widget.manga.id,
      widget.chapter.id,
      pageToSave,
    );
  }

  @override
  void dispose() {
    final readerKey = ReaderKey(mangaId: widget.manga.id, chapterId: widget.chapter.id);
    final currentPage = ref.read(readerProvider(readerKey)).currentPage;
    if (currentPage != _lastSavedPage && currentPage > 0) {
      _saveProgress(currentPage);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(chapterPagesProvider(widget.chapter.id));
    final readerKey = ReaderKey(mangaId: widget.manga.id, chapterId: widget.chapter.id);
    final readerState = ref.watch(readerProvider(readerKey));
    final readerNotifier = ref.read(readerProvider(readerKey).notifier);

    final adjacentParams = AdjacentChaptersParams(
      mangaId: widget.manga.id,
      chapterNumber: widget.chapter.number,
      chapterId: widget.chapter.id,
    );
    final adjacentAsync = ref.watch(adjacentChaptersProvider(adjacentParams));
    final chapterListState = ref.watch(chapterListProvider(widget.manga.id));

    final bgColor = readerState.readerTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: readerState.isOverlayVisible
          ? ReaderAppBar(
              mangaTitle: widget.manga.title,
              chapterTitle: 'Ch.${widget.chapter.number.toInt()}',
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(RouteNames.mangaDetail(widget.mangaSlug));
                }
              },
              onSettings: () => _showSettings(context, readerKey),
              shareUrl:
                  'https://mangahubs.link/manga/${widget.mangaSlug}/chapter-${widget.chapter.number.toInt()}?cid=${widget.chapter.id}',
              chapters: chapterListState.chapters,
              currentChapter: widget.chapter,
              onChapterSelected: (ch) => context.pushReplacement(
                RouteNames.reader(widget.mangaSlug, ch.number, cid: ch.id),
              ),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: pagesAsync.when(
            data: (pages) {
              if (pages.isEmpty) {
                return Center(
                  child: Text(
                    'No pages available',
                    style: TextStyle(color: readerState.readerTheme.textColor),
                  ),
                );
              }
              if (!_initialProgressSaved) {
                _initialProgressSaved = true;
                _saveProgress(1);
              }
              return Stack(
                children: [
                  PageViewer(
                    pages: pages,
                    isVerticalMode: readerState.isVerticalMode,
                    initialPage: readerState.currentPage,
                    onPageChanged: _onPageChanged,
                    onTap: readerNotifier.toggleOverlay,
                  ),
                  if (readerState.brightness < 1.0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: Colors.black
                              .withAlpha(((1 - readerState.brightness) * 180).toInt()),
                        ),
                      ),
                    ),
                  if (readerState.isOverlayVisible)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: adjacentAsync.when(
                        data: (adjacent) => ReaderBottomBar(
                          currentPage: readerState.currentPage == 0
                              ? 1
                              : readerState.currentPage,
                          totalPages: pages.length,
                          previousChapter: adjacent.previous,
                          nextChapter: adjacent.next,
                          onPageChanged: _onPageChanged,
                          onPreviousChapter: adjacent.previous != null
                              ? () => context.pushReplacement(
                                    RouteNames.reader(
                                      widget.mangaSlug,
                                      adjacent.previous!.number,
                                      cid: adjacent.previous!.id,
                                    ),
                                  )
                              : null,
                          onNextChapter: adjacent.next != null
                              ? () => context.pushReplacement(
                                    RouteNames.reader(
                                      widget.mangaSlug,
                                      adjacent.next!.number,
                                      cid: adjacent.next!.id,
                                    ),
                                  )
                              : null,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(
              message: 'Failed to load manga pages.',
              onRetry: () => ref.invalidate(chapterPagesProvider(widget.chapter.id)),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, ReaderKey readerKey) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Consumer(
        builder: (_, ref, __) {
          final state = ref.watch(readerProvider(readerKey));
          final notifier = ref.read(readerProvider(readerKey).notifier);
          return ReaderSettingsPanel(
            isVerticalMode: state.isVerticalMode,
            brightness: state.brightness,
            readerTheme: state.readerTheme,
            onToggleReadingMode: () {
              notifier.toggleReadingMode();
              Navigator.of(context).pop();
            },
            onBrightnessChanged: notifier.setBrightness,
            onThemeChanged: notifier.setTheme,
          );
        },
      ),
    );
  }
}
