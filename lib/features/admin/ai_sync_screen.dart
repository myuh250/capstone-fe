import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AiSyncScreen extends ConsumerStatefulWidget {
  const AiSyncScreen({super.key});

  @override
  ConsumerState<AiSyncScreen> createState() => _AiSyncScreenState();
}

class _AiSyncScreenState extends ConsumerState<AiSyncScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  String? _sessionId;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.aiAdminChat,
        data: {
          'message': text,
          if (_sessionId != null) 'sessionId': _sessionId,
        },
      );

      final reply = response.data['reply'] as String? ?? '';
      _sessionId = response.data['sessionId'] as String?;

      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Error: $e',
          isUser: false,
          isError: true,
        ));
      });
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _sessionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'New conversation',
              onPressed: _clearChat,
            ),
        ],
      ),
      body: Column(
        children: [
          // Hint bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.primary.withValues(alpha: 0.08),
            child: const Text(
              'Admin-only AI with elevated permissions. It can help manage platform data and sync content from MangaDex.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) {
                        return const _TypingIndicator();
                      }
                      return _MessageBubble(message: _messages[i]);
                    },
                  ),
          ),

          // Input
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_outlined,
                size: 64, color: AppColors.textSecondary),
            const Gap(AppSpacing.lg),
            const Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(AppSpacing.sm),
            const Text(
              'Ask questions or request data sync operations',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Gap(AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: 'Fetch 20 trending manga',
                  onTap: () => _controller.text =
                      'Fetch top 20 most recently updated manga and save them',
                ),
                _SuggestionChip(
                  label: 'Sync all genres',
                  onTap: () => _controller.text =
                      'Sync all genres and tags from MangaDex',
                ),
                _SuggestionChip(
                  label: 'Search "One Piece"',
                  onTap: () => _controller.text =
                      'Search MangaDex for "One Piece" and save the results',
                ),
                _SuggestionChip(
                  label: 'How many manga do we have?',
                  onTap: () => _controller.text =
                      'List all tracked manga in the database',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isSending,
              onSubmitted: (_) => _send(),
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: null,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Ask anything or request a sync...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          IconButton.filled(
            onPressed: _isSending ? null : _send,
            icon: const Icon(Icons.send, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Models ───

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final bool isError;
}

// ─── Widgets ───

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.smart_toy, size: 18, color: AppColors.primary),
          ),
          const Gap(AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.2;
                  final t = ((_controller.value + delay) % 1.0);
                  final scale = 0.5 + (t < 0.5 ? t : 1.0 - t) * 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: scale * 0.8),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Opacity(
              opacity: 0.4 + (_controller.value < 0.5
                  ? _controller.value
                  : 1.0 - _controller.value) * 0.6,
              child: const Text(
                'Thinking...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.smart_toy, size: 18, color: AppColors.primary),
            ),
            const Gap(AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: isUser ? null : Border.all(color: AppColors.divider),
              ),
              child: SelectableText(
                widget.message.text,
                style: TextStyle(
                  color: widget.message.isError
                      ? AppColors.error
                      : isUser
                          ? Colors.white
                          : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser) const Gap(AppSpacing.sm),
        ],
      ),
    ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.divider),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}
