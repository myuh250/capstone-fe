import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user.dart';
import '../../providers/admin_providers.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/user_avatar.dart';
import 'widgets/confirm_action_dialog.dart';
import 'widgets/user_status_badge.dart';

// ─── Model ───

class ModerationLogEntry {
  const ModerationLogEntry({
    required this.id,
    required this.action,
    this.note,
    this.moderatorName,
    this.createdAt,
  });

  final int id;
  final String action;
  final String? note;
  final String? moderatorName;
  final DateTime? createdAt;

  factory ModerationLogEntry.fromJson(Map<String, dynamic> json) {
    return ModerationLogEntry(
      id: json['id'] as int,
      action: json['action'] as String? ?? '',
      note: json['note'] as String?,
      moderatorName: json['moderator'] != null
          ? (json['moderator']['username'] as String?)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

// ─── Provider ───

final userModerationLogsProvider =
    FutureProvider.family<List<ModerationLogEntry>, String>((ref, userId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(
    ApiEndpoints.moderationLogsByUser(userId),
  );
  final data = response.data as List<dynamic>? ?? [];
  return data
      .map((e) => ModerationLogEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─── Screen ───

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminUsersProvider);
    final user = state.users.cast<User?>().firstWhere(
          (u) => u?.id == userId,
          orElse: () => null,
        );

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
        ),
        body: const Center(
          child: Text(
            'User not found.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: _UserDetailBody(user: user),
    );
  }
}

class _UserDetailBody extends ConsumerStatefulWidget {
  const _UserDetailBody({required this.user});

  final User user;

  @override
  ConsumerState<_UserDetailBody> createState() => _UserDetailBodyState();
}

class _UserDetailBodyState extends ConsumerState<_UserDetailBody> {
  bool _isActionLoading = false;

  Future<void> _handleToggleStatus() async {
    final user = widget.user;
    final isBanned = user.status == UserStatus.banned;

    final confirmed = await ConfirmActionDialog.show(
      context,
      title: isBanned ? 'Reactivate Account' : 'Deactivate Account',
      message: isBanned
          ? 'Are you sure you want to reactivate ${user.displayName}\'s account?'
          : 'Are you sure you want to deactivate ${user.displayName}\'s account? They will no longer be able to access the platform.',
      confirmLabel: isBanned ? 'Reactivate' : 'Deactivate',
      isDangerous: !isBanned,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isActionLoading = true);

    try {
      await ref.read(adminUsersProvider.notifier).toggleBan(user.id);
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final logsAsync = ref.watch(userModerationLogsProvider(user.id));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ─── Profile Card ───
        _ProfileCard(user: user),
        const Gap(AppSpacing.lg),

        // ─── Action Button ───
        _ActionButton(
          user: user,
          isLoading: _isActionLoading,
          onPressed: _handleToggleStatus,
        ),
        const Gap(AppSpacing.xl),

        // ─── Moderation History ───
        Text(
          'Moderation History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.md),
        logsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => ErrorView(
            message: 'Failed to load moderation history.',
            onRetry: () =>
                ref.invalidate(userModerationLogsProvider(user.id)),
          ),
          data: (logs) => logs.isEmpty
              ? _EmptyLogs()
              : _ModerationLogList(logs: logs),
        ),
      ],
    );
  }
}

// ─── Profile Card ───

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Avatar + Name row
          Row(
            children: [
              UserAvatar(
                imageUrl: user.avatarUrl,
                name: user.displayName,
                size: 64,
              ),
              const Gap(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const Gap(AppSpacing.sm),
                    Row(
                      children: [
                        UserStatusBadge(status: user.status),
                        const Gap(AppSpacing.sm),
                        UserRoleBadge(role: user.role),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),
          const Divider(height: 1, color: AppColors.divider),
          const Gap(AppSpacing.lg),

          // Info rows
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Role',
            value: user.role.label,
          ),
          const Gap(AppSpacing.md),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Registered',
            value: user.createdAt != null
                ? dateFormat.format(user.createdAt!)
                : 'Unknown',
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            _InfoRow(
              icon: Icons.description_outlined,
              label: 'Bio',
              value: user.bio!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const Gap(AppSpacing.sm),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Action Button ───

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.user,
    required this.isLoading,
    required this.onPressed,
  });

  final User user;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isBanned = user.status == UserStatus.banned;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(isBanned ? Icons.check_circle_outline : Icons.block),
        label: Text(isBanned ? 'Reactivate Account' : 'Deactivate Account'),
        style: FilledButton.styleFrom(
          backgroundColor: isBanned ? AppColors.statusGreen : AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    );
  }
}

// ─── Moderation Log List ───

class _EmptyLogs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 40,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const Gap(AppSpacing.sm),
            const Text(
              'No moderation history for this user.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModerationLogList extends StatelessWidget {
  const _ModerationLogList({required this.logs});

  final List<ModerationLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) =>
            _ModerationLogTile(entry: logs[index]),
      ),
    );
  }
}

class _ModerationLogTile extends StatelessWidget {
  const _ModerationLogTile({required this.entry});

  final ModerationLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _actionColor(entry.action).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              _actionIcon(entry.action),
              size: 16,
              color: _actionColor(entry.action),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAction(entry.action),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const Gap(AppSpacing.xs),
                  Text(
                    entry.note!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    if (entry.moderatorName != null) ...[
                      Icon(Icons.admin_panel_settings,
                          size: 12, color: AppColors.textSecondary),
                      const Gap(AppSpacing.xs),
                      Text(
                        entry.moderatorName!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Gap(AppSpacing.md),
                    ],
                    if (entry.createdAt != null) ...[
                      Icon(Icons.access_time,
                          size: 12, color: AppColors.textSecondary),
                      const Gap(AppSpacing.xs),
                      Text(
                        dateFormat.format(entry.createdAt!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAction(String action) {
    // Convert WARN_USER -> Warn User, BAN_USER -> Ban User, etc.
    return action
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Color _actionColor(String action) {
    final upper = action.toUpperCase();
    if (upper.contains('BAN') || upper.contains('DEACTIVATE')) {
      return AppColors.error;
    }
    if (upper.contains('WARN')) {
      return const Color(0xFFF59E0B); // amber/warning
    }
    if (upper.contains('REACTIVATE') || upper.contains('UNBAN')) {
      return AppColors.statusGreen;
    }
    return AppColors.primary;
  }

  IconData _actionIcon(String action) {
    final upper = action.toUpperCase();
    if (upper.contains('BAN') || upper.contains('DEACTIVATE')) {
      return Icons.block;
    }
    if (upper.contains('WARN')) {
      return Icons.warning_amber_rounded;
    }
    if (upper.contains('REACTIVATE') || upper.contains('UNBAN')) {
      return Icons.check_circle_outline;
    }
    return Icons.gavel;
  }
}
