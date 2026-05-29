import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/manga.dart';
import '../../providers/admin_providers.dart';
import '../../providers/manga_providers.dart';
import '../../shared/widgets/cover_image.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';

class MangaEditScreen extends ConsumerWidget {
  const MangaEditScreen({super.key, required this.mangaId});

  final String mangaId;

  bool get isCreateMode => mangaId == 'new';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isCreateMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add New Manga')),
        body: const _MangaEditForm(manga: null),
      );
    }

    final mangaAsync = ref.watch(mangaDetailProvider(mangaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Manga')),
      body: mangaAsync.when(
        data: (manga) => _MangaEditForm(manga: manga),
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: LoadingSkeleton(width: double.infinity, height: 400),
        ),
        error: (e, _) => ErrorView(
          message: 'Failed to load manga details.',
          onRetry: () => ref.invalidate(mangaDetailProvider(mangaId)),
        ),
      ),
    );
  }
}

class _MangaEditForm extends ConsumerStatefulWidget {
  const _MangaEditForm({required this.manga});

  final Manga? manga;

  @override
  ConsumerState<_MangaEditForm> createState() => _MangaEditFormState();
}

class _MangaEditFormState extends ConsumerState<_MangaEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _authorController;
  late final TextEditingController _coverUrlController;
  late MangaStatus _status;
  bool _isSaving = false;

  bool get isCreateMode => widget.manga == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.manga?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.manga?.description ?? '');
    _authorController =
        TextEditingController(text: widget.manga?.author ?? '');
    _coverUrlController =
        TextEditingController(text: widget.manga?.coverUrl ?? '');
    _status = widget.manga?.status ?? MangaStatus.ongoing;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final notifier = ref.read(adminMangaProvider.notifier);
    final statusValue = _status.name.toUpperCase();
    bool success;

    if (isCreateMode) {
      success = await notifier.createManga(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: statusValue,
        coverUrl: _coverUrlController.text.trim().isNotEmpty
            ? _coverUrlController.text.trim()
            : null,
        authorNames: _authorController.text.trim().isNotEmpty
            ? [_authorController.text.trim()]
            : null,
      );
    } else {
      success = await notifier.updateManga(
        mangaId: widget.manga!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: statusValue,
        coverUrl: _coverUrlController.text.trim().isNotEmpty
            ? _coverUrlController.text.trim()
            : null,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCreateMode
              ? 'Manga created successfully!'
              : 'Manga updated successfully!'),
          backgroundColor: AppColors.statusGreen,
        ),
      );
      if (isCreateMode) {
        context.pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverPreview(imageUrl: _coverUrlController.text),
            const Gap(AppSpacing.lg),
            _FormField(
              controller: _coverUrlController,
              label: 'Cover Image URL',
              hint: 'https://example.com/cover.jpg',
              enabled: !_isSaving,
            ),
            const Gap(AppSpacing.lg),
            _FormField(
              controller: _titleController,
              label: 'Title',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
              enabled: !_isSaving,
            ),
            const Gap(AppSpacing.lg),
            _FormField(
              controller: _authorController,
              label: 'Author',
              enabled: !_isSaving,
            ),
            const Gap(AppSpacing.lg),
            _FormField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 5,
              enabled: !_isSaving,
            ),
            const Gap(AppSpacing.lg),
            Text(
              'Status',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const Gap(AppSpacing.sm),
            _StatusSelector(
              selected: _status,
              onChanged: (s) => setState(() => _status = s),
              enabled: !_isSaving,
            ),
            const Gap(AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isCreateMode ? 'Create Manga' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (!isCreateMode) ...[
              const Gap(AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    RouteNames.adminMangaChapters(widget.manga!.id),
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Manage Chapters'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Center(
        child: Container(
          width: 120,
          height: 170,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 40, color: AppColors.textSecondary),
              Gap(AppSpacing.xs),
              Text(
                'No cover',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: SizedBox(
        width: 120,
        child: CoverImage(imageUrl: imageUrl),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.selected,
    required this.onChanged,
    required this.enabled,
  });

  final MangaStatus selected;
  final void Function(MangaStatus) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: MangaStatus.values.map((status) {
        final isSelected = selected == status;
        return ChoiceChip(
          label: Text(_label(status)),
          selected: isSelected,
          onSelected: enabled ? (_) => onChanged(status) : null,
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          backgroundColor: AppColors.surfaceAlt,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }).toList(),
    );
  }

  String _label(MangaStatus status) => switch (status) {
        MangaStatus.ongoing => 'Ongoing',
        MangaStatus.completed => 'Completed',
        MangaStatus.hiatus => 'Hiatus',
        MangaStatus.cancelled => 'Cancelled',
      };
}
