import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum ChatRole { user, bot }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  final ChatRole role;
  final String text;
  final DateTime timestamp;
}

class ChatbotPanel extends ConsumerStatefulWidget {
  const ChatbotPanel({super.key, this.initialContext, this.mangaId, this.chapterId});

  final String? initialContext;
  final String? mangaId;
  final String? chapterId;

  static Future<void> show(BuildContext context, {String? initialContext, String? mangaId, String? chapterId}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChatbotPanel(initialContext: initialContext, mangaId: mangaId, chapterId: chapterId),
    );
  }

  @override
  ConsumerState<ChatbotPanel> createState() => _ChatbotPanelState();
}

class _ChatbotPanelState extends ConsumerState<ChatbotPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  final List<ChatMessage> _messages = [];
  String? _sessionId;

  static const _suggestions = [
    'Suggest action manga',
    'Best completed manga',
    'Manga similar to One Piece',
    'Short manga for quick reads',
  ];

  String get _welcomeMessage => widget.initialContext != null
      ? 'Hello! I can help you learn about "${widget.initialContext}" or suggest other manga. What would you like to know?'
      : 'Hello! I\'m the AI assistant for MangaApp. I can help you find manga, answer questions about content, or give recommendations based on your preferences. How can I help?';

  @override
  void initState() {
    super.initState();
    final storage = ref.read(localStorageProvider);
    _sessionId = storage.getChatSessionId();
    _messages.add(ChatMessage(
      role: ChatRole.bot,
      text: _welcomeMessage,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetSession() {
    ref.read(localStorageProvider).clearChatSession();
    setState(() {
      _messages.clear();
      _sessionId = null;
      _isLoading = false;
      _messages.add(ChatMessage(
        role: ChatRole.bot,
        text: _welcomeMessage,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        role: ChatRole.user,
        text: text,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.aiChat,
        data: {
          'message': text,
          if (widget.mangaId != null) 'mangaId': widget.mangaId,
          if (widget.chapterId != null) 'chapterId': widget.chapterId,
          if (_sessionId != null) 'sessionId': _sessionId,
        },
      );

      if (!mounted) return;

      final data = response.data as Map<String, dynamic>;
      _sessionId = data['sessionId'] as String?;
      if (_sessionId != null) {
        ref.read(localStorageProvider).saveChatSessionId(_sessionId!);
      }
      final reply = data['reply'] as String? ?? 'No response received.';

      setState(() {
        _messages.add(ChatMessage(
          role: ChatRole.bot,
          text: reply,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          role: ChatRole.bot,
          text: 'Sorry, I encountered an error. Please try again.',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          children: [
            _Header(
              onClose: () => Navigator.of(context).pop(),
              onReset: _resetSession,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                itemCount: _messages.length +
                    (_messages.length == 1 ? 1 : 0) +
                    (_isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_messages.length == 1 && i == 1) {
                    return SuggestedQuestions(
                      questions: _suggestions,
                      onTap: _sendMessage,
                    );
                  }
                  if (_isLoading && i == _messages.length + (_messages.length == 1 ? 1 : 0)) {
                    return const _TypingIndicator();
                  }
                  return ChatBubble(message: _messages[i]);
                },
              ),
            ),
            ChatInput(
              controller: _controller,
              isLoading: _isLoading,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose, required this.onReset});

  final VoidCallback onClose;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const Gap(AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Assistant',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'New conversation',
            onPressed: onReset,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isBot = message.role == ChatRole.bot;
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: isBot ? 0 : 48,
        right: isBot ? 48 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isBot ? AppColors.surfaceAlt : AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: isBot
                  ? MarkdownBody(
                      data: message.text,
                      shrinkWrap: true,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                        }
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                        a: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        strong: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        listBullet: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        h1: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        h2: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        h3: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        blockSpacing: 8,
                        listIndent: 16,
                        code: TextStyle(
                          fontSize: 13,
                          backgroundColor: AppColors.surface,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      duration: const Duration(milliseconds: 900),
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
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
        right: 48,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.2;
                  final t = ((_controller.value + delay) % 1.0);
                  final scale = 0.6 + (t < 0.5 ? t : 1.0 - t) * 0.8;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(
                          (scale * 220).toInt(),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: isLoading ? null : onSend,
              decoration: InputDecoration(
                hintText: 'Ask something...',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Gap(AppSpacing.xs),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            onPressed: isLoading
                ? null
                : () => onSend(controller.text),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class SuggestedQuestions extends StatelessWidget {
  const SuggestedQuestions({
    super.key,
    required this.questions,
    required this.onTap,
  });

  final List<String> questions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: questions
            .map(
              (q) => GestureDetector(
                onTap: () => onTap(q),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: AppColors.primary.withAlpha(80),
                    ),
                  ),
                  child: Text(
                    q,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
