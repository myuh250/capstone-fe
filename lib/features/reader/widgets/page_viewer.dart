import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/chapter_page.dart';
import 'page_image.dart';

class PageViewer extends StatefulWidget {
  const PageViewer({
    super.key,
    required this.pages,
    required this.isVerticalMode,
    required this.onPageChanged,
    required this.onTap,
    this.initialPage = 0,
  });

  final List<ChapterPage> pages;
  final bool isVerticalMode;
  final void Function(int page) onPageChanged;
  final VoidCallback onTap;
  final int initialPage;

  @override
  State<PageViewer> createState() => _PageViewerState();
}

class _PageViewerState extends State<PageViewer> {
  late final ScrollController _scrollController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController(initialPage: widget.initialPage);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: widget.isVerticalMode
          ? _buildVerticalScroll()
          : _buildPageFlip(),
    );
  }

  Widget _buildVerticalScroll() {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.scrollDelta == null) return false;
        final position = notification.metrics.pixels;
        final pageHeight = MediaQuery.of(context).size.height;
        final estimatedPage = (position / pageHeight).round() + 1;
        final clampedPage = estimatedPage.clamp(1, widget.pages.length);
        widget.onPageChanged(clampedPage);
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.pages.length,
        itemBuilder: (_, index) => PageImage(page: widget.pages[index]),
      ),
    );
  }

  Widget _buildPageFlip() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.pages.length,
      onPageChanged: (index) => widget.onPageChanged(index + 1),
      itemBuilder: (_, index) {
        return InteractiveViewer(
          child: PageImage(page: widget.pages[index]),
        );
      },
    );
  }
}
