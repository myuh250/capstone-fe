import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
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
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchAndFilterBar(
            onSearchChanged: notifier.search,
            state: state,
            notifier: notifier,
          ),
          Expanded(
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: LoadingSkeleton(width: double.infinity, height: 400),
                  )
                : state.error != null
                    ? ErrorView(
                        message: 'Failed to load user list.',
                        onRetry: () => notifier.refresh(),
                      )
                    : filteredUsers.isEmpty
                        ? const EmptyState(
                            message: 'No users found.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: filteredUsers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final isSelf = currentUser?.id == user.id;
                              return _UserCard(
                                user: user,
                                onTap: () => context.push(
                                  RouteNames.adminUserDetail(user.id),
                                ),
                                isSelf: isSelf,
                                onToggleBan: isSelf
                                    ? null
                                    : () async {
                                        final isBanned =
                                            user.status == UserStatus.banned;
                                        final confirmed =
                                            await ConfirmActionDialog.show(
                                          context,
                                          title: isBanned
                                              ? 'Unban'
                                              : 'Ban Account',
                                          message: isBanned
                                              ? 'Reactivate account "${user.displayName}"?'
                                              : 'Deactivate account "${user.displayName}"? They will no longer be able to log in.',
                                          confirmLabel:
                                              isBanned ? 'Unban' : 'Ban',
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

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.onSearchChanged,
    required this.state,
    required this.notifier,
  });

  final void Function(String) onSearchChanged;
  final AdminUsersState state;
  final AdminUsersNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
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
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              _FilterChip(
                label: 'All Roles',
                isSelected: state.roleFilter == null,
                onTap: () => notifier.setRoleFilter(null),
              ),
              const Gap(AppSpacing.sm),
              _FilterChip(
                label: 'Reader',
                isSelected: state.roleFilter == UserRole.user,
                onTap: () => notifier.setRoleFilter(UserRole.user),
              ),
              const Gap(AppSpacing.sm),
              _FilterChip(
                label: 'Admin',
                isSelected: state.roleFilter == UserRole.admin,
                onTap: () => notifier.setRoleFilter(UserRole.admin),
              ),
              const Gap(AppSpacing.md),
              Container(
                width: 1,
                height: 24,
                color: AppColors.divider,
              ),
              const Gap(AppSpacing.md),
              _FilterChip(
                label: 'All Status',
                isSelected: state.statusFilter == null,
                onTap: () => notifier.setStatusFilter(null),
              ),
              const Gap(AppSpacing.sm),
              _FilterChip(
                label: 'Active',
                isSelected: state.statusFilter == UserStatus.active,
                onTap: () => notifier.setStatusFilter(UserStatus.active),
              ),
              const Gap(AppSpacing.sm),
              _FilterChip(
                label: 'Banned',
                isSelected: state.statusFilter == UserStatus.banned,
                onTap: () => notifier.setStatusFilter(UserStatus.banned),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.sm),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onTap,
    this.onToggleBan,
    this.isSelf = false,
  });

  final User user;
  final VoidCallback onTap;
  final VoidCallback? onToggleBan;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
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
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
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
            if (!isSelf)
              IconButton(
                icon: Icon(
                  user.status == UserStatus.banned
                      ? Icons.lock_open
                      : Icons.block,
                  size: 20,
                  color: user.status == UserStatus.banned
                      ? AppColors.statusGreen
                      : AppColors.error,
                ),
                tooltip:
                    user.status == UserStatus.banned ? 'Unban' : 'Ban Account',
                onPressed: onToggleBan,
              ),
          ],
        ),
      ),
    );
  }
}
