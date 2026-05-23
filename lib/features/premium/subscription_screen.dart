import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/payment.dart';
import '../../providers/subscription_providers.dart';
import 'widgets/plan_card.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  SubscriptionPlan _selected = SubscriptionPlan.yearly;

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(activeSubscriptionProvider);
    final activeSub = subscriptionState.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        actions: [
          TextButton(
            onPressed: () => context.push(RouteNames.paymentHistory),
            child: const Text(
              'History',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PremiumHeroSection(),
            if (activeSub != null) ...[
              const Gap(AppSpacing.xl),
              _ActiveSubscriptionBanner(subscription: activeSub),
            ] else ...[
              const Gap(AppSpacing.xl),
              Text(
                'Choose a Plan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Gap(AppSpacing.md),
              ...SubscriptionPlan.values.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: PlanCard(
                      plan: plan,
                      isSelected: _selected == plan,
                      onSelect: () => setState(() => _selected = plan),
                    ),
                  )),
              const Gap(AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  onPressed: () =>
                      context.push(RouteNames.payment, extra: _selected),
                  child: Text(
                    'Continue — ${_selected.formattedPrice}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),
              Center(
                child: Text(
                  'You can cancel anytime. '
                  'By continuing, you agree to the Terms of Service.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveSubscriptionBanner extends StatelessWidget {
  const _ActiveSubscriptionBanner({required this.subscription});

  final SubscriptionInfo subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.statusGreen.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.statusGreen.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.statusGreen, size: 20),
              const Gap(AppSpacing.sm),
              Text(
                'Premium Plan Active',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.statusGreen,
                    ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Text(
            'Plan: Premium ${subscription.plan.label}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(AppSpacing.xs),
          Text(
            'Expires: ${subscription.expiryDate.day}/${subscription.expiryDate.month}/${subscription.expiryDate.year}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const features = [
      (Icons.block, 'Ad-free', 'Read manga smoothly without interruptions'),
      (Icons.download_outlined, 'Offline Reading', 'Download and read without an internet connection'),
      (Icons.flash_on_outlined, 'Early Access', 'Access new chapters before everyone else'),
      (Icons.support_agent_outlined, 'Priority Support', 'Get faster support responses'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF9C56FF)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
              const Gap(AppSpacing.sm),
              Text(
                'MangaApp Premium',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(f.$1, color: Colors.white, size: 20),
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          f.$3,
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
