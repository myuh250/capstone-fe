import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/auth_providers.dart';
import '../../../shared/widgets/user_avatar.dart';

class CommentInput extends ConsumerStatefulWidget {
  const CommentInput({
    super.key,
    required this.onSubmit,
    this.hintText = 'Write a comment...',
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

  List<Map<String, String>> _mentionResults = [];
  bool _showMentionDropdown = false;
  String _mentionQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    if (widget.isCompact) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);

    _detectMention();
  }

  void _detectMention() {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    if (cursorPos < 0) return;

    final beforeCursor = text.substring(0, cursorPos);
    final atIndex = beforeCursor.lastIndexOf('@');

    if (atIndex == -1) {
      _hideMentionDropdown();
      return;
    }

    final charBeforeAt = atIndex > 0 ? beforeCursor[atIndex - 1] : ' ';
    if (atIndex > 0 && charBeforeAt != ' ' && charBeforeAt != '\n') {
      _hideMentionDropdown();
      return;
    }

    final query = beforeCursor.substring(atIndex + 1);
    if (query.contains(' ') || query.contains('\n')) {
      _hideMentionDropdown();
      return;
    }

    _mentionQuery = query;
    if (query.isEmpty) {
      _hideMentionDropdown();
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      _searchUsers(query);
    });
  }

  Future<void> _searchUsers(String query) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        ApiEndpoints.mentionSearch,
        queryParameters: {'q': query},
      );
      final data = response.data as List<dynamic>;
      final results = data
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
      if (mounted && _mentionQuery == query) {
        setState(() {
          _mentionResults = results;
          _showMentionDropdown = results.isNotEmpty;
        });
      }
    } catch (_) {
      _hideMentionDropdown();
    }
  }

  void _hideMentionDropdown() {
    if (_showMentionDropdown) {
      setState(() {
        _showMentionDropdown = false;
        _mentionResults = [];
      });
    }
  }

  void _insertMention(String username) {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    final beforeCursor = text.substring(0, cursorPos);
    final afterCursor = text.substring(cursorPos);
    final atIndex = beforeCursor.lastIndexOf('@');

    final newText = '${beforeCursor.substring(0, atIndex)}@$username $afterCursor';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: atIndex + username.length + 2),
    );

    _hideMentionDropdown();
    _focusNode.requestFocus();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showMentionDropdown) _buildMentionDropdown(),
        Container(
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
                        'Cancel',
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
        ),
      ],
    );
  }

  Widget _buildMentionDropdown() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _mentionResults.length,
        itemBuilder: (context, index) {
          final user = _mentionResults[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _insertMention(user['username']!),
              hoverColor: AppColors.primary.withAlpha(20),
              splashColor: AppColors.primary.withAlpha(40),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: index < _mentionResults.length - 1
                      ? const Border(
                          bottom: BorderSide(
                            color: AppColors.divider,
                            width: 0.5,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    UserAvatar(
                      imageUrl: user['avatarUrl']!.isNotEmpty
                          ? user['avatarUrl']
                          : null,
                      name: user['displayName'] ?? user['username']!,
                      size: 28,
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '@${user['username']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          if (user['displayName'] != user['username'])
                            Text(
                              user['displayName'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary.withAlpha(150),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
