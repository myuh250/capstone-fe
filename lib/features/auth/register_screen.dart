import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_strength_indicator.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );

    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    authState.whenOrNull(
      data: (user) {
        if (user != null) context.go(RouteNames.verifyEmail);
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString()}'),
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
                  const Gap(AppSpacing.xl),
                  Text(
                    'Tạo tài khoản',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    'Tham gia cộng đồng đọc manga ngay hôm nay.',
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
                          controller: _nameController,
                          label: 'Tên hiển thị',
                          hint: 'Manga Reader',
                          prefixIcon: Icons.person_outline,
                          validator: Validators.displayName,
                          enabled: !isLoading,
                        ),
                        const Gap(AppSpacing.lg),
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
                        _PasswordWithStrength(
                          controller: _passwordController,
                          isLoading: isLoading,
                        ),
                        const Gap(AppSpacing.lg),
                        AuthTextField(
                          controller: _confirmController,
                          label: 'Xác nhận mật khẩu',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (v) => Validators.confirmPassword(
                            v,
                            _passwordController.text,
                          ),
                          onFieldSubmitted: (_) => _onSubmit(),
                          enabled: !isLoading,
                        ),
                        const Gap(AppSpacing.xl),
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
                                  'Đăng ký',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordWithStrength extends StatefulWidget {
  const _PasswordWithStrength({
    required this.controller,
    required this.isLoading,
  });

  final TextEditingController controller;
  final bool isLoading;

  @override
  State<_PasswordWithStrength> createState() => _PasswordWithStrengthState();
}

class _PasswordWithStrengthState extends State<_PasswordWithStrength> {
  String _password = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() => _password = widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthTextField(
          controller: widget.controller,
          label: 'Mật khẩu',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: Validators.password,
          enabled: !widget.isLoading,
        ),
        if (_password.isNotEmpty) ...[
          const Gap(AppSpacing.sm),
          PasswordStrengthIndicator(password: _password),
        ],
      ],
    );
  }
}
