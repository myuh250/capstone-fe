import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../providers/auth_providers.dart';
import 'widgets/avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _nameController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
  }

  void _onChanged() {
    final user = ref.read(currentUserProvider);
    final changed = _nameController.text != (user?.displayName ?? '') ||
        _bioController.text != (user?.bio ?? '');
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).updateProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.statusGreen,
        ),
      );
      if (context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onPickAvatar() async {
    final user = ref.read(currentUserProvider);
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => _AvatarOptionsSheet(showRemove: hasAvatar),
    );
    if (result == null || !mounted) return;

    if (result == 'remove') {
      await _removeAvatar();
      return;
    }

    await _pickAndUploadAvatar();
  }

  Future<void> _removeAvatar() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).removeAvatar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar removed'),
            backgroundColor: AppColors.statusGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove avatar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final result = await ImagePickerHelper.pickImage();
    if (result == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).uploadAvatar(
        result.bytes,
        result.name,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated'),
            backgroundColor: AppColors.statusGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload avatar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: (_isLoading || !_hasChanges) ? null : _onSave,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: AvatarPicker(
                  imageUrl: user?.avatarUrl,
                  name: user?.displayName ?? '',
                  onPickImage: _onPickAvatar,
                  size: 88,
                ),
              ),
              const Gap(AppSpacing.xxl),
              _SectionLabel('Personal Information'),
              const Gap(AppSpacing.sm),
              _ProfileField(
                controller: _nameController,
                label: 'Display Name',
                hint: 'Enter your display name',
                maxLength: 30,
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  if (v.trim().length > 30) {
                    return 'Name must be at most 30 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.md),
              _ProfileField(
                controller: _bioController,
                label: 'About',
                hint: 'Write a few words about yourself...',
                maxLines: 4,
                maxLength: 200,
                enabled: !_isLoading,
              ),
              const Gap(AppSpacing.xxl),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOptionsSheet extends StatelessWidget {
  const _AvatarOptionsSheet({this.showRemove = false});

  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              'Change Avatar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose Image'),
            onTap: () => Navigator.of(context).pop('gallery'),
          ),
          if (showRemove)
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Remove Avatar',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.of(context).pop('remove'),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
