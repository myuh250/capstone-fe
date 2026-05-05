import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_dashboard.dart';
import '../../features/admin/content_management_screen.dart';
import '../../features/admin/manga_edit_screen.dart';
import '../../features/admin/user_management_screen.dart';
import '../../features/admin/widgets/admin_shell.dart';
import '../../features/auth/email_verification_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/manga_detail/manga_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reader/reader_screen.dart';
import '../../features/search/search_screen.dart';
import '../../models/user.dart';
import '../../providers/auth_providers.dart';
import '../../shared/widgets/app_shell.dart';
import 'route_names.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRefreshListenable = _AuthRefreshListenable();

  ref.listen(authStateProvider, (_, __) {
    authRefreshListenable.notify();
  });

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.home,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAdmin = user?.role == UserRole.admin;
      final loc = state.matchedLocation;

      final isAuthRoute = loc.startsWith('/auth');
      final isAdminRoute = loc.startsWith('/admin');
      final isUserRoute = !isAuthRoute && !isAdminRoute;

      // Chưa đăng nhập → về login
      if (!isLoggedIn && !isAuthRoute) return RouteNames.login;

      // Đã đăng nhập, đang ở trang auth → điều hướng theo role
      if (isLoggedIn && isAuthRoute) {
        return isAdmin ? RouteNames.admin : RouteNames.home;
      }

      // Admin cố vào route của user → về admin panel
      if (isLoggedIn && isAdmin && isUserRoute) {
        return RouteNames.admin;
      }

      // User thường cố vào admin route → về trang chủ
      if (isLoggedIn && !isAdmin && isAdminRoute) {
        return RouteNames.home;
      }

      return null;
    },
    refreshListenable: authRefreshListenable,
    routes: [
      // ── Auth routes ──────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verifyEmail',
        builder: (_, __) => const EmailVerificationScreen(),
      ),

      // ── User routes (AppShell) ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.search,
            name: 'search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: RouteNames.library,
            name: 'library',
            builder: (_, __) =>
                const _PlaceholderScreen(title: 'Thư viện'),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Manga / Reader (không có shell nav) ──────────────────
      GoRoute(
        path: '/manga/:mangaId',
        name: 'mangaDetail',
        builder: (context, state) => MangaDetailScreen(
          mangaId: state.pathParameters['mangaId']!,
        ),
        routes: [
          GoRoute(
            path: 'chapter/:chapterId',
            name: 'reader',
            builder: (context, state) => ReaderScreen(
              mangaId: state.pathParameters['mangaId']!,
              chapterId: state.pathParameters['chapterId']!,
            ),
          ),
        ],
      ),

      // ── Admin routes (AdminShell) ─────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.admin,
            name: 'admin',
            builder: (_, __) => const AdminDashboard(),
          ),
          GoRoute(
            path: RouteNames.adminUsers,
            name: 'adminUsers',
            builder: (_, __) => const UserManagementScreen(),
          ),
          GoRoute(
            path: RouteNames.adminContent,
            name: 'adminContent',
            builder: (_, __) => const ContentManagementScreen(),
          ),
          GoRoute(
            path: '/admin/content/manga/:mangaId/edit',
            name: 'adminMangaEdit',
            builder: (context, state) => MangaEditScreen(
              mangaId: state.pathParameters['mangaId']!,
            ),
          ),
          GoRoute(
            path: RouteNames.adminModeration,
            name: 'adminModeration',
            builder: (_, __) =>
                const _PlaceholderScreen(title: 'Kiểm duyệt'),
          ),
          GoRoute(
            path: RouteNames.adminReports,
            name: 'adminReports',
            builder: (_, __) =>
                const _PlaceholderScreen(title: 'Báo cáo'),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Lỗi trang')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Không tìm thấy trang: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Đang phát triển...'),
          ],
        ),
      ),
    );
  }
}
