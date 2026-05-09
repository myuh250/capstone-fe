import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mật khẩu đã được thay đổi thành công'),
        backgroundColor: AppColors.statusGreen,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
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
                        'Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm chữ cái và số.',
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
                label: 'Mật khẩu hiện tại',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.xl),
              AuthTextField(
                controller: _newController,
                label: 'Mật khẩu mới',
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
                label: 'Xác nhận mật khẩu mới',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (v) {
                  if (v != _newController.text) {
                    return 'Mật khẩu không khớp';
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
                        'Đổi mật khẩu',
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
