import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/payment.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/transaction_card.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  static final List<Transaction> _fakeTransactions = [
    Transaction(
      id: 't1',
      plan: SubscriptionPlan.yearly,
      method: PaymentMethod.momo,
      status: PaymentStatus.success,
      amount: SubscriptionPlan.yearly.priceVnd,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Transaction(
      id: 't2',
      plan: SubscriptionPlan.monthly,
      method: PaymentMethod.vnpay,
      status: PaymentStatus.success,
      amount: SubscriptionPlan.monthly.priceVnd,
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
    ),
    Transaction(
      id: 't3',
      plan: SubscriptionPlan.monthly,
      method: PaymentMethod.momo,
      status: PaymentStatus.failed,
      amount: SubscriptionPlan.monthly.priceVnd,
      createdAt: DateTime.now().subtract(const Duration(days: 65)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử thanh toán')),
      body: _fakeTransactions.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Chưa có giao dịch nào',
            )
          : Column(
              children: [
                _SummaryBanner(transactions: _fakeTransactions),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _fakeTransactions.length,
                    itemBuilder: (_, i) =>
                        TransactionCard(transaction: _fakeTransactions[i]),
                  ),
                ),
              ],
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
