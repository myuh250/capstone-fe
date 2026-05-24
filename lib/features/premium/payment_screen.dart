import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/payment.dart';
import '../../providers/subscription_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final PaymentMethod _method = PaymentMethod.vnpay;
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.createPayment(
        plan: widget.plan,
        method: _method,
      );
      if (!mounted) return;

      if (result.requiresRedirect) {
        final url = Uri.parse(result.redirectUrl!);
        if (kIsWeb) {
          // Web: redirect in same tab so user returns to our app
          await launchUrl(url, webOnlyWindowName: '_self');
        } else {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        return;
      }

      if (result.isSuccess) {
        ref.read(activeSubscriptionProvider.notifier).load();
      }

      context.pushReplacement(
        RouteNames.paymentResult,
        extra: (success: result.isSuccess, plan: widget.plan, method: _method),
      );
    } catch (e) {
      if (!mounted) return;
      context.pushReplacement(
        RouteNames.paymentResult,
        extra: (success: false, plan: widget.plan, method: _method),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderSummary(plan: widget.plan),
                  const Gap(AppSpacing.xl),
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF005BAC),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: const Center(
                            child: Text(
                              'VN\nPAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VNPAY',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Text(
                                'Pay with VNPAY',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border:
                                Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: const Icon(Icons.check,
                              size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _PayButton(
            plan: widget.plan,
            isLoading: _isLoading,
            onPay: _processPayment,
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Gap(AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Premium ${plan.label} Plan',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                plan.formattedPrice,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          const Divider(color: AppColors.divider),
          const Gap(AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                plan.formattedPrice,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.plan,
    required this.isLoading,
    required this.onPay,
  });

  final SubscriptionPlan plan;
  final bool isLoading;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          onPressed: isLoading ? null : onPay,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Pay ${plan.formattedPrice}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
