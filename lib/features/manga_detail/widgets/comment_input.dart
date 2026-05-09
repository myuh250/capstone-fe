import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/auth_providers.dart';
import '../../../shared/widgets/user_avatar.dart';

class CommentInput extends ConsumerStatefulWidget {
  const CommentInput({
    super.key,
    required this.onSubmit,
    this.hintText = 'Viết bình luận...',
    this.onCancel,
    this.isCompact = false,
  });

  final Future<bool> Function(String text) onSubmit;
  final String hintText;
  final VoidCallback? onCancel;
  final bool isCompact;

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    if (widget.isCompact) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmitting = true);
    final ok = await widget.onSubmit(text);
    if (ok && mounted) {
      _controller.clear();
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Container(
      padding: EdgeInsets.all(
        widget.isCompact ? AppSpacing.sm : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: widget.isCompact
            ? Border.all(color: AppColors.divider)
            : const Border(
                top: BorderSide(color: AppColors.divider),
              ),
        borderRadius: widget.isCompact
            ? BorderRadius.circular(AppSpacing.radiusMd)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isCompact) ...[
            UserAvatar(
              imageUrl: user?.avatarUrl,
              name: user?.displayName ?? '?',
              size: 32,
            ),
            const Gap(AppSpacing.sm),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: 14),
              textInputAction: TextInputAction.newline,
            ),
          ),
          const Gap(AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (_isSubmitting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: _hasText ? AppColors.primary : AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: _hasText ? _submit : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
