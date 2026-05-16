import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/payment.dart';
import '../../providers/subscription_providers.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/transaction_card.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử thanh toán')),
      body: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Chưa có giao dịch nào',
            );
          }
          return Column(
            children: [
              _SummaryBanner(transactions: transactions),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: transactions.length,
                  itemBuilder: (_, i) =>
                      TransactionCard(transaction: transactions[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final successful = transactions
        .where((t) => t.status == PaymentStatus.success)
        .toList();
    final totalSpent =
        successful.fold<int>(0, (sum, t) => sum + t.amount);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C56FF)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Tổng giao dịch',
              value: '${transactions.length}',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _Stat(
              label: 'Thành công',
              value: '${successful.length}',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _Stat(
              label: 'Đã chi',
              value: '${SubscriptionPlanExtension.formatNumber(totalSpent)}đ',
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(200),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
