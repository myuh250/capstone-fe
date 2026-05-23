import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/comment.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/comment_providers.dart';
import 'comment_card.dart';
import 'comment_input.dart';
import 'reply_thread.dart';

class CommentSection extends ConsumerWidget {
  const CommentSection({super.key, required this.mangaId});

  final String mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsState = ref.watch(commentsProvider(mangaId));
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(
                'Comments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!commentsState.isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '${commentsState.comments.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (commentsState.isLoading)
          const _CommentSkeleton()
        else if (commentsState.error != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(commentsProvider(mangaId).notifier).refresh(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reload comments'),
              ),
            ),
          )
        else if (commentsState.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Center(
              child: Text(
                'No comments yet. Be the first!',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: commentsState.comments.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppSpacing.lg,
            ),
            itemBuilder: (_, i) {
              final comment = commentsState.comments[i];
              return _CommentItem(
                comment: comment,
                mangaId: mangaId,
              );
            },
          ),
        const Divider(height: 1, color: AppColors.divider),
        if (isLoggedIn)
          CommentInput(
            onSubmit: (text) =>
                ref.read(commentsProvider(mangaId).notifier).addComment(text),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'Sign in to comment',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        const Gap(AppSpacing.md),
      ],
    );
  }
}

class _CommentItem extends ConsumerStatefulWidget {
  const _CommentItem({
    required this.comment,
    required this.mangaId,
  });

  final Comment comment;
  final String mangaId;

  @override
  ConsumerState<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<_CommentItem> {
  bool _showReplyInput = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentCard(
            comment: widget.comment,
            onReply: () => setState(() => _showReplyInput = true),
            onDelete: widget.comment.userId == 'current_user'
                ? () => ref
                    .read(commentsProvider(widget.mangaId).notifier)
                    .deleteComment(widget.comment.id)
                : null,
          ),
          ReplyThread(
            parentComment: widget.comment,
            mangaId: widget.mangaId,
          ),
          if (_showReplyInput)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xxl + AppSpacing.md,
                top: AppSpacing.sm,
              ),
              child: CommentInput(
                hintText: 'Reply to ${widget.comment.userName}...',
                onSubmit: (text) async {
                  final ok = await ref
                      .read(commentsProvider(widget.mangaId).notifier)
                      .replyToComment(widget.comment.id, text);
                  if (ok) setState(() => _showReplyInput = false);
                  return ok;
                },
                onCancel: () => setState(() => _showReplyInput = false),
                isCompact: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentSkeleton extends StatelessWidget {
  const _CommentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 100, color: AppColors.surfaceAlt),
                    const SizedBox(height: AppSpacing.sm),
                    Container(height: 12, color: AppColors.surfaceAlt),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 200, color: AppColors.surfaceAlt),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
