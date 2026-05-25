import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import '../auth/widgets/auth_text_field.dart';
import '../auth/widgets/password_strength_indicator.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: AppColors.statusGreen,
        ),
      );
      if (context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('incorrect')
          ? 'Current password is incorrect'
          : 'Failed to change password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.statusBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.statusBlue.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.statusBlue,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'New password must be at least 8 characters, including letters and numbers.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.statusBlue,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.xl),
              AuthTextField(
                controller: _currentController,
                label: 'Current Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter your password' : null,
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.xl),
              AuthTextField(
                controller: _newController,
                label: 'New Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: Validators.password,
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.sm),
              ValueListenableBuilder(
                valueListenable: _newController,
                builder: (_, __, ___) => PasswordStrengthIndicator(
                  password: _newController.text,
                ),
              ),
              const Gap(AppSpacing.lg),
              AuthTextField(
                controller: _confirmController,
                label: 'Confirm New Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (v) {
                  if (v != _newController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.xxl),
              FilledButton(
                onPressed: _isLoading ? null : _onSubmit,
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
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
