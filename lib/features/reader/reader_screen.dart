import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/manga_providers.dart';
import '../../providers/reader_providers.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/page_viewer.dart';
import 'widgets/reader_app_bar.dart';
import 'widgets/reader_bottom_bar.dart';
import 'widgets/reader_settings_panel.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({
    super.key,
    required this.mangaId,
    required this.chapterId,
  });

  final String mangaId;
  final String chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(chapterPagesProvider(chapterId));
    final mangaAsync = ref.watch(mangaDetailProvider(mangaId));
    final readerKey = ReaderKey(mangaId: mangaId, chapterId: chapterId);
    final readerState = ref.watch(readerProvider(readerKey));
    final readerNotifier = ref.read(readerProvider(readerKey).notifier);

    final chapterNumber = _extractChapterNumber(chapterId);
    final adjacentParams = AdjacentChaptersParams(
      mangaId: mangaId,
      chapterNumber: chapterNumber,
    );
    final adjacentAsync = ref.watch(adjacentChaptersProvider(adjacentParams));

    final bgColor = readerState.readerTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: readerState.isOverlayVisible
          ? ReaderAppBar(
              mangaTitle: mangaAsync.valueOrNull?.title ?? 'Manga',
              chapterTitle: 'Ch.${chapterNumber.toInt()}',
              onBack: () => context.pop(),
              onSettings: () => _showSettings(context, ref, readerKey),
              shareUrl:
                  'https://mangaapp.example.com/manga/$mangaId/chapter/$chapterId',
            )
          : null,
      body: pagesAsync.when(
        data: (pages) {
          if (pages.isEmpty) {
            return Center(
              child: Text(
                'Không có trang nào',
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
              // Brightness overlay
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
                          ? () => _navigateToChapter(
                                context,
                                adjacent.previous!.id,
                              )
                          : null,
                      onNextChapter: adjacent.next != null
                          ? () => _navigateToChapter(
                                context,
                                adjacent.next!.id,
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
          message: 'Không thể tải trang manga.',
          onRetry: () => ref.invalidate(chapterPagesProvider(chapterId)),
        ),
      ),
    );
  }

  double _extractChapterNumber(String chapterId) {
    final parts = chapterId.split('_ch_');
    if (parts.length >= 2) {
      return double.tryParse(parts.last) ?? 1.0;
    }
    return 1.0;
  }

  void _navigateToChapter(BuildContext context, String newChapterId) {
    context.pushReplacement('/manga/$mangaId/chapter/$newChapterId');
  }

  void _showSettings(
    BuildContext context,
    WidgetRef ref,
    ReaderKey readerKey,
  ) {
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
