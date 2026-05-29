import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/admin_providers.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/confirm_action_dialog.dart';

final _chaptersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, mangaId) async {
    final repo = ref.read(adminRepositoryProvider);
    return repo.getChaptersByManga(mangaId);
  },
);

class ChapterManagementScreen extends ConsumerWidget {
  const ChapterManagementScreen({super.key, required this.mangaId});

  final String mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(_chaptersProvider(mangaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Chapters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Chapter',
            onPressed: () => _showAddChapterDialog(context, ref),
          ),
        ],
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          if (chapters.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const Gap(AppSpacing.md),
                  const Text(
                    'No chapters yet',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const Gap(AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: () => _showAddChapterDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Chapter'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: chapters.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final ch = chapters[index];
              final chNum = ch['chapterNumber'] as num?;
              final title = ch['title'] as String? ?? '';
              final id = ch['id'] as String;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${chNum?.toInt() ?? index + 1}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.isNotEmpty
                                ? 'Ch. ${chNum?.toInt() ?? ''} - $title'
                                : 'Chapter ${chNum?.toInt() ?? index + 1}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () async {
                        final confirmed = await ConfirmActionDialog.show(
                          context,
                          title: 'Delete Chapter',
                          message:
                              'Delete Chapter ${chNum?.toInt() ?? ''}? This cannot be undone.',
                          confirmLabel: 'Delete',
                          isDangerous: true,
                        );
                        if (confirmed) {
                          final repo = ref.read(adminRepositoryProvider);
                          await repo.deleteChapter(id);
                          ref.invalidate(_chaptersProvider(mangaId));
                        }
                      },
                      color: AppColors.error,
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: LoadingSkeleton(width: double.infinity, height: 300),
        ),
        error: (e, _) => ErrorView(
          message: 'Failed to load chapters.',
          onRetry: () => ref.invalidate(_chaptersProvider(mangaId)),
        ),
      ),
    );
  }

  void _showAddChapterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddChapterDialog(
        mangaId: mangaId,
        onCreated: () => ref.invalidate(_chaptersProvider(mangaId)),
      ),
    );
  }
}

class _AddChapterDialog extends ConsumerStatefulWidget {
  const _AddChapterDialog({required this.mangaId, required this.onCreated});

  final String mangaId;
  final VoidCallback onCreated;

  @override
  ConsumerState<_AddChapterDialog> createState() => _AddChapterDialogState();
}

class _AddChapterDialogState extends ConsumerState<_AddChapterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _titleController = TextEditingController();
  final _urlsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _numberController.dispose();
    _titleController.dispose();
    _urlsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final number = double.tryParse(_numberController.text.trim()) ?? 1;
    final title = _titleController.text.trim();
    final urlsText = _urlsController.text.trim();
    final imageUrls = urlsText.isNotEmpty
        ? urlsText
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList()
        : <String>[];

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.createChapter(
        mangaId: widget.mangaId,
        chapterNumber: number,
        title: title.isNotEmpty ? title : null,
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
      );
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create chapter: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Add Chapter'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chapter Number *',
                  hintText: 'e.g. 1',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) return 'Must be a number';
                  return null;
                },
              ),
              const Gap(AppSpacing.md),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Chapter Title (optional)',
                  hintText: 'e.g. The Beginning',
                ),
              ),
              const Gap(AppSpacing.md),
              TextFormField(
                controller: _urlsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Page Image URLs (one per line)',
                  hintText:
                      'https://cdn.example.com/page1.jpg\nhttps://cdn.example.com/page2.jpg',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
