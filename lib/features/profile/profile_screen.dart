import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user.dart';
import '../../providers/auth_providers.dart';
import '../../shared/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const _NotLoggedIn()
          : _ProfileContent(user: user),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: AppSpacing.sm),
          _SettingsSection(
            items: [
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => context.push(RouteNames.editProfile),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => context.push(RouteNames.changePassword),
              ),
              _SettingsTile(
                icon: Icons.settings_outlined,
                label: 'Account Settings',
                onTap: () => context.push(RouteNames.settings),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsSection(
            items: [
              _SettingsTile(
                icon: Icons.workspace_premium_outlined,
                label: 'Upgrade to Premium',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                onTap: () => context.push(RouteNames.premium),
              ),
              _SettingsTile(
                icon: Icons.receipt_long_outlined,
                label: 'Payment History',
                onTap: () => context.push(RouteNames.paymentHistory),
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                label: 'Downloaded Manga',
                onTap: () => context.push(RouteNames.downloads),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsSection(
            items: [
              _SettingsTile(
                icon: Icons.help_outline,
                label: 'Help',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                label: 'About',
                onTap: () {},
              ),
            ],
          ),
          const Gap(AppSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        children: [
          UserAvatar(
            imageUrl: user.avatarUrl,
            name: user.displayName,
            size: 80,
          ),
          const Gap(AppSpacing.md),
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Gap(AppSpacing.xs),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Gap(AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoleBadge(role: user.role),
              if (user.isPremium) ...[
                const Gap(AppSpacing.sm),
                const _PremiumBadge(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (role) {
      UserRole.admin => (AppColors.primary, 'Admin'),
      UserRole.moderator => (AppColors.statusBlue, 'Moderator'),
      UserRole.user => (AppColors.textSecondary, 'Member'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.ratingYellow.withAlpha(38),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.ratingYellow.withAlpha(100)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: AppColors.ratingYellow),
          SizedBox(width: 3),
          Text(
            'Premium',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.ratingYellow,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.items});

  final List<_SettingsTile> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: AppSpacing.lg + 44,
          color: AppColors.divider,
        ),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
      minLeadingWidth: 28,
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Not logged in',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
