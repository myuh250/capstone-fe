import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user.dart';
import '../../providers/admin_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/user_avatar.dart';
import 'widgets/confirm_action_dialog.dart';
import 'widgets/user_status_badge.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminUsersProvider);
    final notifier = ref.read(adminUsersProvider.notifier);
    final filteredUsers = notifier.filteredUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: notifier.search),
          Expanded(
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: LoadingSkeleton(width: double.infinity, height: 400),
                  )
                : state.error != null
                    ? ErrorView(
                        message: 'Không thể tải danh sách người dùng.',
                        onRetry: () {},
                      )
                    : filteredUsers.isEmpty
                        ? const EmptyState(
                            message: 'Không tìm thấy người dùng nào.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: filteredUsers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              return _UserCard(
                                user: filteredUsers[index],
                                onChangeRole: (role) =>
                                    notifier.changeRole(filteredUsers[index].id, role),
                                onToggleBan: () async {
                                  final user = filteredUsers[index];
                                  final isBanned =
                                      user.status == UserStatus.banned;
                                  final confirmed = await ConfirmActionDialog.show(
                                    context,
                                    title: isBanned ? 'Mở khóa' : 'Khóa tài khoản',
                                    message: isBanned
                                        ? 'Mở khóa tài khoản ${user.displayName}?'
                                        : 'Khóa tài khoản ${user.displayName}?',
                                    confirmLabel: isBanned ? 'Mở khóa' : 'Khóa',
                                    isDangerous: !isBanned,
                                  );
                                  if (confirmed) {
                                    notifier.toggleBan(user.id);
                                  }
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm người dùng...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onChangeRole,
    required this.onToggleBan,
  });

  final User user;
  final void Function(UserRole role) onChangeRole;
  final VoidCallback onToggleBan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: user.avatarUrl,
            name: user.displayName,
            size: 44,
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    UserStatusBadge(status: user.status),
                    const Gap(AppSpacing.xs),
                    UserRoleBadge(role: user.role),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _ActionMenu(
            user: user,
            onChangeRole: onChangeRole,
            onToggleBan: onToggleBan,
          ),
        ],
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.user,
    required this.onChangeRole,
    required this.onToggleBan,
  });

  final User user;
  final void Function(UserRole role) onChangeRole;
  final VoidCallback onToggleBan;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      color: AppColors.surface,
      itemBuilder: (_) => [
        if (user.role != UserRole.admin)
          PopupMenuItem(
            value: 'make_admin',
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 18),
                Gap(AppSpacing.sm),
                Text('Đặt làm Admin'),
              ],
            ),
          ),
        if (user.role != UserRole.user)
          PopupMenuItem(
            value: 'make_user',
            child: const Row(
              children: [
                Icon(Icons.person_outline, size: 18),
                Gap(AppSpacing.sm),
                Text('Đặt làm User'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'toggle_ban',
          child: Row(
            children: [
              Icon(
                user.status == UserStatus.banned ? Icons.lock_open : Icons.block,
                size: 18,
                color: user.status == UserStatus.banned
                    ? AppColors.statusGreen
                    : AppColors.error,
              ),
              const Gap(AppSpacing.sm),
              Text(user.status == UserStatus.banned ? 'Mở khóa' : 'Khóa tài khoản'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'make_admin':
            onChangeRole(UserRole.admin);
          case 'make_user':
            onChangeRole(UserRole.user);
          case 'toggle_ban':
            onToggleBan();
        }
      },
    );
  }
}
