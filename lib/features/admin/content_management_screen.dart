import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/manga.dart';
import '../../providers/admin_providers.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/confirm_action_dialog.dart';

class ContentManagementScreen extends ConsumerWidget {
  const ContentManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminMangaProvider);
    final notifier = ref.read(adminMangaProvider.notifier);
    final filteredManga = notifier.filteredManga;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(RouteNames.adminMangaEdit('new')),
            tooltip: 'Add new manga',
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: notifier.search),
          Expanded(
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: LoadingSkeleton(width: double.infinity, height: 400),
                  )
                : state.error != null
                    ? ErrorView(
                        message: 'Failed to load manga list.',
                        onRetry: () => ref.read(adminMangaProvider.notifier).refresh(),
                      )
                    : filteredManga.isEmpty
                        ? const EmptyState(
                            message: 'No manga found.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: filteredManga.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              return _MangaAdminCard(
                                manga: filteredManga[index],
                                onEdit: () => context.push(
                                  RouteNames.adminMangaEdit(
                                    filteredManga[index].id,
                                  ),
                                ),
                                onDelete: () async {
                                  final confirmed =
                                      await ConfirmActionDialog.show(
                                    context,
                                    title: 'Delete Manga',
                                    message:
                                        'Delete "${filteredManga[index].title}"? This action cannot be undone.',
                                    confirmLabel: 'Delete',
                                    isDangerous: true,
                                  );
                                  if (confirmed) {
                                    notifier.deleteManga(
                                      filteredManga[index].id,
                                    );
                                  }
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search manga...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _MangaAdminCard extends StatelessWidget {
  const _MangaAdminCard({
    required this.manga,
    required this.onEdit,
    required this.onDelete,
  });

  final Manga manga;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: CoverImage(imageUrl: manga.coverUrl),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  manga.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${manga.totalChapters} chapters  •  ${_mangaStatusLabel(manga.status)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _mangaStatusLabel(MangaStatus status) => switch (status) {
      MangaStatus.ongoing => 'Ongoing',
      MangaStatus.completed => 'Completed',
      MangaStatus.hiatus => 'Hiatus',
      MangaStatus.cancelled => 'Cancelled',
    };
