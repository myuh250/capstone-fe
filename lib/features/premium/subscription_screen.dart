import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/payment.dart';
import 'widgets/plan_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionPlan _selected = SubscriptionPlan.yearly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nâng cấp Premium'),
        actions: [
          TextButton(
            onPressed: () => context.push(RouteNames.paymentHistory),
            child: const Text(
              'Lịch sử',
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
            const Gap(AppSpacing.xl),
            Text(
              'Chọn gói',
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
                  'Tiếp tục — ${_selected.formattedPrice}',
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
                'Bạn có thể hủy bất cứ lúc nào. '
                'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumHeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const features = [
      (Icons.block, 'Không quảng cáo', 'Đọc manga mượt mà, không gián đoạn'),
      (Icons.download_outlined, 'Đọc offline', 'Tải về và đọc khi không có mạng'),
      (Icons.flash_on_outlined, 'Đọc trước', 'Truy cập chương mới trước người khác'),
      (Icons.support_agent_outlined, 'Hỗ trợ ưu tiên', 'Được hỗ trợ nhanh hơn'),
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
