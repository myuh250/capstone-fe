import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/chapter.dart';
import '../../../shared/widgets/share_button.dart';

class ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReaderAppBar({
    super.key,
    required this.mangaTitle,
    required this.chapterTitle,
    required this.onBack,
    this.onSettings,
    this.shareUrl,
    this.chapters = const [],
    this.currentChapter,
    this.onChapterSelected,
  });

  final String mangaTitle;
  final String chapterTitle;
  final VoidCallback onBack;
  final VoidCallback? onSettings;
  final String? shareUrl;
  final List<Chapter> chapters;
  final Chapter? currentChapter;
  final void Function(Chapter chapter)? onChapterSelected;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.85),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack,
      ),
      centerTitle: true,
      title: chapters.isNotEmpty && onChapterSelected != null
          ? Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentChapter?.id,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  icon: const Icon(Icons.expand_more, color: Colors.white70, size: 18),
                  items: chapters.map((ch) {
                    return DropdownMenuItem(
                      value: ch.id,
                      child: Text(
                        'Ch.${ch.number.toInt()}${ch.title != null ? " - ${ch.title}" : ""}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final ch = chapters.firstWhere((c) => c.id == id);
                    onChapterSelected!(ch);
                  },
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mangaTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  chapterTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
      actions: [
        if (shareUrl != null)
          ShareButton(
            title: mangaTitle,
            url: shareUrl!,
            compact: true,
            color: Colors.white,
          ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: onSettings,
        ),
      ],
    );
  }
}
