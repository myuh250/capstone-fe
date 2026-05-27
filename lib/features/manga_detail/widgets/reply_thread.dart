import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/comment.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/comment_providers.dart';
import 'comment_card.dart';
import 'comment_input.dart';

class ReplyThread extends ConsumerStatefulWidget {
  const ReplyThread({
    super.key,
    required this.parentComment,
    required this.mangaId,
  });

  final Comment parentComment;
  final String mangaId;

  @override
  ConsumerState<ReplyThread> createState() => _ReplyThreadState();
}

class _ReplyThreadState extends ConsumerState<ReplyThread> {
  bool _showReplies = false;
  bool _showInput = false;

  @override
  Widget build(BuildContext context) {
    final replies = widget.parentComment.replies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xxl + AppSpacing.md + 36 + AppSpacing.sm,
              top: AppSpacing.xs,
            ),
            child: InkWell(
              onTap: () => setState(() => _showReplies = !_showReplies),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showReplies
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showReplies
                          ? 'Hide ${replies.length} replies'
                          : 'View ${replies.length} replies',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_showReplies)
          Builder(builder: (context) {
            final currentUser = ref.watch(currentUserProvider);
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: replies.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final isOwner = currentUser != null &&
                    replies[i].userId == currentUser.id;
                return CommentCard(
                  comment: replies[i],
                  isReply: true,
                  isOwner: isOwner,
                  onReply: () => setState(() => _showInput = true),
                  onDelete: isOwner
                      ? () => ref
                          .read(commentsProvider(widget.mangaId).notifier)
                          .deleteComment(replies[i].id)
                      : null,
                );
              },
            );
          }),
        if (_showInput) ...[
          const Gap(AppSpacing.sm),
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xxl + AppSpacing.md,
            ),
            child: CommentInput(
              hintText: 'Reply to ${widget.parentComment.userName}...',
              onSubmit: (text) async {
                final ok = await ref
                    .read(commentsProvider(widget.mangaId).notifier)
                    .replyToComment(widget.parentComment.id, text);
                if (ok) setState(() => _showInput = false);
                return ok;
              },
              onCancel: () => setState(() => _showInput = false),
              isCompact: true,
            ),
          ),
        ],
      ],
    );
  }
}
