import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../providers/manga_providers.dart';
import '../../home/widgets/manga_horizontal_list.dart';
import '../../home/widgets/manga_section_header.dart';

class RelatedMangaSection extends ConsumerWidget {
  const RelatedMangaSection({
    super.key,
    required this.mangaId,
    required this.onTapManga,
  });

  final String mangaId;
  final void Function(String mangaId) onTapManga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedMangaProvider(mangaId));

    return relatedAsync.when(
      data: (related) {
        if (related.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: MangaSectionHeader(title: 'Manga liên quan'),
              ),
              const Gap(AppSpacing.md),
              MangaHorizontalList(
                items: related,
                onTapManga: (m) => onTapManga(m.id),
              ),
              const Gap(AppSpacing.xl),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
