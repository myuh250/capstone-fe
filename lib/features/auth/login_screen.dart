import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static const _googleClientId =
      '41764157266-ucn2amkv1glm6jhg4c0jil8177g8e8qv.apps.googleusercontent.com';

  Future<void> _onGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? _googleClientId : null,
        serverClientId: kIsWeb ? null : _googleClientId,
        // On web, requesting OIDC scopes is required to reliably get an `idToken`.
        // Empty scopes can result in `idToken == null`.
        scopes: const ['openid', 'email', 'profile'],
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception(
          'Failed to get Google ID token. '
          'Ensure the OAuth client is type "Web application" in Google Cloud Console.',
        );
      }

      await ref.read(authStateProvider.notifier).googleLogin(idToken: idToken);

      if (!mounted) return;
      final authState = ref.read(authStateProvider);
      authState.whenOrNull(
        data: (user) {
          if (user != null) context.go(RouteNames.home);
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-In thất bại: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    authState.whenOrNull(
      data: (user) {
        if (user != null) context.go(RouteNames.home);
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AppLogo(),
                  const Gap(AppSpacing.xxxl),
                  Text(
                    'Đăng nhập',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    'Chào mừng trở lại! Đăng nhập để tiếp tục đọc manga.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Gap(AppSpacing.xxl),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'your@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          enabled: !isLoading,
                        ),
                        const Gap(AppSpacing.lg),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                          onFieldSubmitted: (_) => _onSubmit(),
                          enabled: !isLoading,
                        ),
                        const Gap(AppSpacing.sm),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: isLoading
                                  ? null
                                  : (v) =>
                                      setState(() => _rememberMe = v ?? false),
                              activeColor: AppColors.primary,
                            ),
                            const Text('Nhớ đăng nhập'),
                            const Spacer(),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.push(
                                        RouteNames.forgotPassword,
                                      ),
                              child: const Text(
                                'Quên mật khẩu?',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.lg),
                        FilledButton(
                          onPressed: isLoading ? null : _onSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const Gap(AppSpacing.lg),
                        const _OrDivider(),
                        const Gap(AppSpacing.lg),
                        GoogleSignInButton(
                          onPressed:
                              (isLoading || _isGoogleLoading)
                                  ? null
                                  : _onGoogleSignIn,
                          isLoading: _isGoogleLoading,
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push(RouteNames.register),
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.divider, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'hoặc',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.divider, thickness: 1),
        ),
      ],
    );
  }
}

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
        ),
        const Gap(AppSpacing.md),
        Text(
          'MangaApp',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}
