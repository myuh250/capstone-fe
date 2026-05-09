import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/chatbot/chatbot_panel.dart';
import '../../features/notifications/widgets/notification_card.dart';
import '../../providers/auth_providers.dart';
import '../../providers/notification_providers.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      path: RouteNames.home,
    ),
    _NavItem(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      label: 'Search',
      path: RouteNames.search,
    ),
    _NavItem(
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books,
      label: 'Library',
      path: RouteNames.library,
    ),
    _NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      path: RouteNames.profile,
    ),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop || context.isTablet) {
      return Row(
        children: [
          _buildSidebar(),
          Expanded(child: widget.child),
        ],
      );
    } else {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: FloatingActionButton.small(
          heroTag: 'chatbot_fab',
          backgroundColor: AppColors.primary,
          tooltip: 'Trợ lý AI',
          onPressed: () => ChatbotPanel.show(context),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        ),
      );
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Manga Reader',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return _SidebarNavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onNavItemTapped(index),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _SidebarNotificationButton(
            onTap: () => context.push(RouteNames.notifications),
          ),
          _SidebarLogoutButton(
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      items: _navItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: Material(
        color: isSelected ? AppColors.surfaceAlt : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  item.label,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarLogoutButton extends StatelessWidget {
  const _SidebarLogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: const Row(
              children: [
                Icon(Icons.logout, color: AppColors.error, size: 24),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarNotificationButton extends ConsumerWidget {
  const _SidebarNotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                NotificationBadge(
                  count: unread,
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Thông báo',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (unread > 0) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
}
