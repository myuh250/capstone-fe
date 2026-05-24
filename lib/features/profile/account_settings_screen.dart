import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState
    extends ConsumerState<AccountSettingsScreen> {
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _newChapterNotif = true;
  bool _commentNotif = true;
  bool _systemNotif = true;

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted after 30 days.',
        ),
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
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feature not yet integrated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SwitchTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SwitchTile(
                icon: Icons.notifications_outlined,
                label: 'All Notifications',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              _SwitchTile(
                icon: Icons.auto_stories_outlined,
                label: 'New Chapters',
                subtitle: 'Get notified when your favorite manga has new chapters',
                value: _newChapterNotif && _notificationsEnabled,
                onChanged: _notificationsEnabled
                    ? (v) => setState(() => _newChapterNotif = v)
                    : null,
              ),
              _SwitchTile(
                icon: Icons.chat_bubble_outline,
                label: 'Comment Replies',
                value: _commentNotif && _notificationsEnabled,
                onChanged: _notificationsEnabled
                    ? (v) => setState(() => _commentNotif = v)
                    : null,
              ),
              _SwitchTile(
                icon: Icons.campaign_outlined,
                label: 'System Notifications',
                value: _systemNotif && _notificationsEnabled,
                onChanged: _notificationsEnabled
                    ? (v) => setState(() => _systemNotif = v)
                    : null,
              ),
            ],
          ),
          _SettingsSection(
            title: 'Language',
            children: [
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                title: const Text('App Language'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'English',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(
                  Icons.security_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                title: const Text('Login & Security'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.download_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                title: const Text('Export Data'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: AppColors.error,
                  size: 22,
                ),
                title: Text(
                  'Delete Account',
                  style: TextStyle(color: AppColors.error),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.error,
                  size: 20,
                ),
                onTap: _confirmDeleteAccount,
              ),
            ],
          ),
          const Gap(AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
          ),
        ),
        Container(
          color: AppColors.surface,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: AppSpacing.lg + 44,
              color: AppColors.divider,
            ),
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }
}
