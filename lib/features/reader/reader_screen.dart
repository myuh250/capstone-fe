import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../providers/reader_providers.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/page_viewer.dart';
import 'widgets/reader_app_bar.dart';
import 'widgets/reader_bottom_bar.dart';
import 'widgets/reader_settings_panel.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({
    super.key,
    required this.mangaSlug,
    required this.chapterSlug,
  });

  final String mangaSlug;
  final String chapterSlug;

  double get _chapterNumber {
    final match = RegExp(r'chapter-(.+)').firstMatch(chapterSlug);
    if (match != null) return double.tryParse(match.group(1)!) ?? 1.0;
    return 1.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ReaderParams(mangaSlug: mangaSlug, chapterNumber: _chapterNumber);
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

class _ReaderContent extends ConsumerWidget {
  const _ReaderContent({
    required this.manga,
    required this.chapter,
    required this.mangaSlug,
  });

  final Manga manga;
  final Chapter chapter;
  final String mangaSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(chapterPagesProvider(chapter.id));
    final readerKey = ReaderKey(mangaId: manga.id, chapterId: chapter.id);
    final readerState = ref.watch(readerProvider(readerKey));
    final readerNotifier = ref.read(readerProvider(readerKey).notifier);

    final adjacentParams = AdjacentChaptersParams(
      mangaId: manga.id,
      chapterNumber: chapter.number,
    );
    final adjacentAsync = ref.watch(adjacentChaptersProvider(adjacentParams));

    final bgColor = readerState.readerTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: readerState.isOverlayVisible
          ? ReaderAppBar(
              mangaTitle: manga.title,
              chapterTitle: 'Ch.${chapter.number.toInt()}',
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(RouteNames.mangaDetail(mangaSlug));
                }
              },
              onSettings: () => _showSettings(context, ref, readerKey),
              shareUrl:
                  'https://mangahubs.link/manga/$mangaSlug/chapter-${chapter.number.toInt()}',
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
              return Stack(
                children: [
                  PageViewer(
                    pages: pages,
                    isVerticalMode: readerState.isVerticalMode,
                    initialPage: readerState.currentPage,
                    onPageChanged: readerNotifier.setPage,
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
                          onPageChanged: readerNotifier.setPage,
                          onPreviousChapter: adjacent.previous != null
                              ? () => context.pushReplacement(
                                    RouteNames.reader(mangaSlug, adjacent.previous!.number),
                                  )
                              : null,
                          onNextChapter: adjacent.next != null
                              ? () => context.pushReplacement(
                                    RouteNames.reader(mangaSlug, adjacent.next!.number),
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
              onRetry: () => ref.invalidate(chapterPagesProvider(chapter.id)),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref, ReaderKey readerKey) {
    final state = ref.read(readerProvider(readerKey));
    final notifier = ref.read(readerProvider(readerKey).notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReaderSettingsPanel(
        isVerticalMode: state.isVerticalMode,
        brightness: state.brightness,
        readerTheme: state.readerTheme,
        autoNextChapter: state.autoNextChapter,
        onToggleReadingMode: notifier.toggleReadingMode,
        onBrightnessChanged: notifier.setBrightness,
        onThemeChanged: notifier.setTheme,
        onAutoNextChanged: notifier.setAutoNextChapter,
      ),
    );
  }
}
