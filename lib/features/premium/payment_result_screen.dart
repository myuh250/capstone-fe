import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/payment.dart';
import '../../providers/subscription_providers.dart';

class PaymentResultScreen extends ConsumerStatefulWidget {
  const PaymentResultScreen({
    super.key,
    required this.success,
    required this.plan,
    required this.method,
  });

  final bool success;
  final SubscriptionPlan plan;
  final PaymentMethod method;

  @override
  ConsumerState<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.success) {
      ref.read(activeSubscriptionProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final success = widget.success;
    final plan = widget.plan;
    final method = widget.method;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _ResultIcon(success: success),
                const Gap(AppSpacing.xl),
                Text(
                  success ? 'Payment Successful!' : 'Payment Failed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: success
                            ? AppColors.statusGreen
                            : AppColors.error,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSpacing.md),
                Text(
                  success
                      ? 'Congratulations! You have successfully upgraded to the ${plan.label} plan. Enjoy the Premium experience!'
                      : 'The transaction could not be completed. Please try again or choose a different payment method.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (success) ...[
                  const Gap(AppSpacing.xl),
                  _TransactionDetails(plan: plan, method: method, ref: ref),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          success ? AppColors.primary : AppColors.error,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md + 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    onPressed: () => context.go(RouteNames.home),
                    child: Text(
                      success ? 'Go to Home' : 'Try Again',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (!success) ...[
                  const Gap(AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Try Again'),
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

class _ResultIcon extends StatelessWidget {
  const _ResultIcon({required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: success
              ? AppColors.statusGreen.withAlpha(30)
              : AppColors.error.withAlpha(30),
        ),
        child: Icon(
          success ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 72,
          color: success ? AppColors.statusGreen : AppColors.error,
        ),
      ),
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({
    required this.plan,
    required this.method,
    required this.ref,
  });

  final SubscriptionPlan plan;
  final PaymentMethod method;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(activeSubscriptionProvider).valueOrNull;
    final expiryStr = sub != null
        ? '${sub.expiryDate.day}/${sub.expiryDate.month}/${sub.expiryDate.year}'
        : 'Loading...';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          _Row(label: 'Plan', value: 'Premium ${plan.label}'),
          const Gap(AppSpacing.sm),
          _Row(label: 'Method', value: method.label),
          const Gap(AppSpacing.sm),
          _Row(label: 'Amount', value: plan.formattedPrice),
          const Gap(AppSpacing.sm),
          _Row(label: 'Expires', value: expiryStr),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
