import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_dashboard.dart';
import '../../features/admin/content_management_screen.dart';
import '../../features/admin/manga_edit_screen.dart';
import '../../features/admin/moderation_screen.dart';
import '../../features/admin/report_dashboard.dart';
import '../../features/admin/report_detail_screen.dart';
import '../../features/admin/user_management_screen.dart';
import '../../features/admin/widgets/admin_shell.dart';
import '../../features/auth/email_verification_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/downloads/downloads_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/library/reading_history_screen.dart';
import '../../features/manga_detail/manga_detail_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/premium/payment_history_screen.dart';
import '../../features/premium/payment_result_screen.dart';
import '../../features/premium/payment_screen.dart';
import '../../features/premium/subscription_screen.dart';
import '../../features/profile/account_settings_screen.dart';
import '../../features/profile/change_password_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reader/reader_screen.dart';
import '../../features/search/search_screen.dart';
import '../../models/payment.dart';
import '../../models/user.dart';
import '../../providers/auth_providers.dart';
import '../../shared/widgets/app_shell.dart';
import 'route_names.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRefreshListenable = _AuthRefreshListenable();

  ref.listen(authStateProvider, (_, __) {
    authRefreshListenable.notify();
  });

  GoRouter.optionURLReflectsImperativeAPIs = true;

  return GoRouter(
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAdmin = user?.role == UserRole.admin;
      final loc = state.matchedLocation;

      final isAuthRoute = loc.startsWith('/auth');
      final isPaymentCallback = loc.startsWith('/payment/vnpay-return');
      final isAdminRoute = loc.startsWith('/admin');
      final isUserRoute = !isAuthRoute && !isAdminRoute && !isPaymentCallback;

      // Not logged in → redirect to login (except payment callbacks)
      if (!isLoggedIn && !isAuthRoute && !isPaymentCallback) return RouteNames.login;

      // Logged in, on auth page → redirect by role
      if (isLoggedIn && isAuthRoute) {
        return isAdmin ? RouteNames.admin : RouteNames.home;
      }

      // Admin trying to access user route → redirect to admin panel
      if (isLoggedIn && isAdmin && isUserRoute) {
        return RouteNames.admin;
      }

      // Regular user trying to access admin route → redirect to home
      if (isLoggedIn && !isAdmin && isAdminRoute) {
        return RouteNames.home;
      }

      return null;
    },
    refreshListenable: authRefreshListenable,
    routes: [
      // ── Payment callback (outside auth shell) ───────────────
      GoRoute(
        path: '/payment/vnpay-return',
        name: 'vnpayReturn',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final success = params['success'] == 'true';
          final planStr = params['plan'];
          final plan = planStr != null
              ? SubscriptionPlanExtension.fromString(planStr)
              : SubscriptionPlan.monthly;
          return PaymentResultScreen(
            success: success,
            plan: plan,
            method: PaymentMethod.vnpay,
          );
        },
      ),

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
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'resetPassword',
        builder: (_, __) => const ResetPasswordScreen(),
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
            builder: (_, __) => const LibraryScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.editProfile,
            name: 'editProfile',
            builder: (_, __) => const EditProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.changePassword,
            name: 'changePassword',
            builder: (_, __) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            name: 'accountSettings',
            builder: (_, __) => const AccountSettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.readingHistory,
            name: 'readingHistory',
            builder: (_, __) => const ReadingHistoryScreen(),
          ),
          GoRoute(
            path: RouteNames.downloads,
            name: 'downloads',
            builder: (_, __) => const DownloadsScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.subscription,
            name: 'subscription',
            builder: (_, __) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: RouteNames.payment,
            name: 'payment',
            builder: (context, state) {
              final plan = state.extra as SubscriptionPlan? ??
                  SubscriptionPlan.monthly;
              return PaymentScreen(plan: plan);
            },
          ),
          GoRoute(
            path: RouteNames.paymentResult,
            name: 'paymentResult',
            builder: (context, state) {
              final extra = state.extra
                  as ({bool success, SubscriptionPlan plan, PaymentMethod method})?;
              return PaymentResultScreen(
                success: extra?.success ?? false,
                plan: extra?.plan ?? SubscriptionPlan.monthly,
                method: extra?.method ?? PaymentMethod.vnpay,
              );
            },
          ),
          GoRoute(
            path: RouteNames.paymentHistory,
            name: 'paymentHistory',
            builder: (_, __) => const PaymentHistoryScreen(),
          ),
        ],
      ),

      // ── Manga / Reader (no shell nav) ──────────────────
      GoRoute(
        path: '/manga/:mangaSlug',
        name: 'mangaDetail',
        builder: (context, state) => MangaDetailScreen(
          mangaSlug: state.pathParameters['mangaSlug']!,
          scrollTo: state.uri.queryParameters['scrollTo'],
        ),
        routes: [
          GoRoute(
            path: ':chapterSlug',
            name: 'reader',
            builder: (context, state) => ReaderScreen(
              mangaSlug: state.pathParameters['mangaSlug']!,
              chapterSlug: state.pathParameters['chapterSlug']!,
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
            builder: (_, __) => const ModerationScreen(),
          ),
          GoRoute(
            path: RouteNames.adminReports,
            name: 'adminReports',
            builder: (_, __) => const ReportDashboard(),
            routes: [
              GoRoute(
                path: ':reportId',
                name: 'reportDetail',
                builder: (context, state) => ReportDetailScreen(
                  reportId: state.pathParameters['reportId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go to Home'),
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
