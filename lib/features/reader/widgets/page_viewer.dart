import 'package:flutter/gestures.dart';
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
  int _currentPage = 0;
  bool _isJumping = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _scrollController = ScrollController();
    _pageController = PageController(
      initialPage: (widget.initialPage - 1).clamp(0, widget.pages.length - 1),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didUpdateWidget(covariant PageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.initialPage;
    if (target != _currentPage && target >= 1 && target <= widget.pages.length) {
      _currentPage = target;
      _isJumping = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.isVerticalMode) {
          if (_scrollController.hasClients) {
            final pageHeight = MediaQuery.of(context).size.height;
            _scrollController.jumpTo((target - 1) * pageHeight);
          }
        } else {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(target - 1);
          }
        }
        _isJumping = false;
      });
    }
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
        if (_isJumping) return false;
        if (notification.scrollDelta == null) return false;
        final position = notification.metrics.pixels;
        final pageHeight = MediaQuery.of(context).size.height;
        final estimatedPage = (position / pageHeight).round() + 1;
        final clampedPage = estimatedPage.clamp(1, widget.pages.length);
        _currentPage = clampedPage;
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
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.pages.length,
        onPageChanged: (index) {
          if (_isJumping) return;
          _currentPage = index + 1;
          widget.onPageChanged(index + 1);
        },
        itemBuilder: (_, index) {
          return InteractiveViewer(
            child: PageImage(page: widget.pages[index]),
          );
        },
      ),
    );
  }
}
