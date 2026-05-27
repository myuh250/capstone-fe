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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

enum _RegisterStep { form, otp }

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  _RegisterStep _step = _RegisterStep.form;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendRegistrationOtp(
            _emailController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = _RegisterStep.otp;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to send verification code. Please try again.';
      });
    }
  }

  Future<void> _verifyAndRegister() async {
    if (_otpValue.length < 6) {
      setState(() => _error = 'Please enter the full 6-digit code');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
            otp: _otpValue,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(RouteNames.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message ?? 'Invalid code. Please try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Registration failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: switch (_step) {
                _RegisterStep.form => _buildFormStep(),
                _RegisterStep.otp => _buildOtpStep(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(AppSpacing.xl),
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          'Join the manga reading community today.',
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
                label: 'Display Name',
                hint: 'Manga Reader',
                prefixIcon: Icons.person_outline,
                validator: Validators.displayName,
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.lg),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'your@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.lg),
              _PasswordWithStrength(
                controller: _passwordController,
                isLoading: _isLoading,
              ),
              const Gap(AppSpacing.lg),
              AuthTextField(
                controller: _confirmController,
                label: 'Confirm Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.confirmPassword(
                  v,
                  _passwordController.text,
                ),
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
          onPressed: _isLoading ? null : _sendOtp,
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
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
        const Gap(AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: _isLoading ? null : () => context.pop(),
              child: const Text(
                'Sign In',
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
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(AppSpacing.xl),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const Gap(AppSpacing.xl),
        Text(
          'Verify Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Gap(AppSpacing.sm),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            children: [
              const TextSpan(text: 'We sent a 6-digit code to '),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '. Enter it below to complete registration.'),
            ],
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
          onPressed: _isLoading ? null : _verifyAndRegister,
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
                  'Verify & Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
        const Gap(AppSpacing.lg),
        OutlinedButton(
          onPressed: _isLoading
              ? null
              : () {
                  for (final c in _otpControllers) {
                    c.clear();
                  }
                  setState(() {
                    _error = null;
                    _step = _RegisterStep.form;
                  });
                },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: const Text(
            'Back',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Gap(AppSpacing.lg),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendOtp,
            child: const Text(
              'Resend Code',
              style: TextStyle(color: AppColors.primary),
            ),
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
          label: 'Password',
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
