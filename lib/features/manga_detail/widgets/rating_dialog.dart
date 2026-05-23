import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/comment_providers.dart';

Future<void> showRatingDialog(
  BuildContext context, {
  required WidgetRef ref,
  required String mangaId,
  required String mangaTitle,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    builder: (_) => ProviderScope(
      overrides: [],
      child: _RatingBottomSheet(
        ref: ref,
        mangaId: mangaId,
        mangaTitle: mangaTitle,
      ),
    ),
  );
}

class _RatingBottomSheet extends ConsumerStatefulWidget {
  const _RatingBottomSheet({
    required this.ref,
    required this.mangaId,
    required this.mangaTitle,
  });

  final WidgetRef ref;
  final String mangaId;
  final String mangaTitle;

  @override
  ConsumerState<_RatingBottomSheet> createState() =>
      _RatingBottomSheetState();
}

class _RatingBottomSheetState extends ConsumerState<_RatingBottomSheet> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  static const _labels = ['', 'Terrible', 'Poor', 'Average', 'Good', 'Excellent'];

  @override
  void initState() {
    super.initState();
    final current = widget.ref.read(userRatingProvider(widget.mangaId)).valueOrNull;
    if (current != null) _selectedRating = current;
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) return;
    setState(() => _isSubmitting = true);
    await ref
        .read(userRatingProvider(widget.mangaId).notifier)
        .submitRating(_selectedRating);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const Gap(AppSpacing.xl),
            Text(
              'Rate this manga',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Gap(AppSpacing.sm),
            Text(
              widget.mangaTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _selectedRating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.ratingYellow,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.sm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _selectedRating > 0 ? _labels[_selectedRating] : 'Select a rating',
                key: ValueKey(_selectedRating),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _selectedRating > 0
                          ? AppColors.ratingYellow
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Gap(AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed:
                        (_isSubmitting || _selectedRating == 0) ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
