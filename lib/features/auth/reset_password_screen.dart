import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exceptions.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_strength_indicator.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

enum _Step { otp, newPassword, success }

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _Step _step = _Step.otp;
  bool _isLoading = false;
  String? _error;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is String && extra.isNotEmpty) {
      _email = extra;
    }
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpValue.length < 6) {
      setState(() => _error = 'Please enter the full 6-digit code');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyOtp(email: _email, otp: _otpValue);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = _Step.newPassword;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message ?? 'Invalid OTP. Please try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Invalid OTP. Please try again.';
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: _email,
        otp: _otpValue,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = _Step.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message ?? 'Failed to reset password.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to reset password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: switch (_step) {
                _Step.otp => _buildOtpStep(),
                _Step.newPassword => _buildPasswordStep(),
                _Step.success => _buildSuccessStep(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pin_outlined,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const Gap(AppSpacing.xl),
        Text(
          'Enter Verification Code',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          'Enter the 6-digit code sent to $_email',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Gap(AppSpacing.xxl),
        _OtpRow(
          controllers: _otpControllers,
          focusNodes: _otpFocusNodes,
          enabled: !_isLoading,
        ),
        if (_error != null) ...[
          const Gap(AppSpacing.md),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const Gap(AppSpacing.xl),
        FilledButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Verify Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const Gap(AppSpacing.xl),
        Text(
          'Set New Password',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          'Choose a strong password for your account.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Gap(AppSpacing.xxl),
        Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _passwordController,
                label: 'New Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: Validators.password,
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.sm),
              ValueListenableBuilder(
                valueListenable: _passwordController,
                builder: (_, __, ___) => PasswordStrengthIndicator(
                  password: _passwordController.text,
                ),
              ),
              const Gap(AppSpacing.lg),
              AuthTextField(
                controller: _confirmController,
                label: 'Confirm Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (v) {
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const Gap(AppSpacing.md),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
        const Gap(AppSpacing.xl),
        FilledButton(
          onPressed: _isLoading ? null : _resetPassword,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.statusGreen.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 36,
            color: AppColors.statusGreen,
          ),
        ),
        const Gap(AppSpacing.xl),
        Text(
          'Password Reset Successful!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          'Your password has been changed. You can now sign in with your new password.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Gap(AppSpacing.xxl),
        FilledButton(
          onPressed: () => context.go(RouteNames.login),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: const Text(
            'Sign In Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _OtpRow extends StatelessWidget {
  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.enabled,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool enabled;

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (i) => SizedBox(
          width: 44,
          height: 56,
          child: TextFormField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            onChanged: (v) => _onChanged(v, i),
          ),
        ),
      ),
    );
  }
}
