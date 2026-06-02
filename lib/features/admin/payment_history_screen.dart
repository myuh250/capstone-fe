import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/admin_providers.dart';
import '../../repositories/admin_repository.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';

class AdminPaymentHistoryScreen extends ConsumerStatefulWidget {
  const AdminPaymentHistoryScreen({super.key});

  @override
  ConsumerState<AdminPaymentHistoryScreen> createState() =>
      _AdminPaymentHistoryScreenState();
}

class _AdminPaymentHistoryScreenState extends ConsumerState<AdminPaymentHistoryScreen> {
  String? _statusFilter;
  String _searchQuery = '';
  int _currentPage = 0;

  final _searchController = TextEditingController();
  final _debouncer = _Debouncer(milliseconds: 400);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  (String?, String?, int) get _providerKey =>
      (_statusFilter, _searchQuery.isEmpty ? null : _searchQuery, _currentPage);

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(adminPaymentsProvider(_providerKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildFilters(context),
            const Gap(AppSpacing.lg),
            Expanded(
              child: paymentsAsync.when(
                data: (result) => _buildContent(context, result),
                loading: () => const LoadingSkeleton(
                    width: double.infinity, height: 400),
                error: (e, _) => ErrorView(
                  message: 'Failed to load payments.',
                  onRetry: _refresh,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by username or transaction ref...',
              hintStyle: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              _debouncer.run(() {
                setState(() {
                  _searchQuery = value.trim();
                  _currentPage = 0;
                });
              });
            },
          ),
        ),
        const Gap(AppSpacing.md),
        _buildStatusFilter(),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _statusFilter,
          hint: const Text(
            'All Status',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          isDense: true,
          dropdownColor: AppColors.surface,
          items: const [
            DropdownMenuItem(
                value: null,
                child: Text('All Status', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(
                value: 'SUCCESS',
                child: Text('Success', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(
                value: 'PENDING',
                child: Text('Pending', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(
                value: 'FAILED',
                child: Text('Failed', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(
                value: 'CANCELLED',
                child: Text('Cancelled', style: TextStyle(fontSize: 13))),
          ],
          onChanged: (value) {
            setState(() {
              _statusFilter = value;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminPaymentsResult result) {
    if (result.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const Gap(AppSpacing.md),
            const Text(
              'No transactions found.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: _buildTable(context, result.payments)),
        if (result.totalPages > 1) ...[
          const Gap(AppSpacing.md),
          _buildPagination(result),
        ],
      ],
    );
  }

  Widget _buildTable(BuildContext context, List<AdminPayment> payments) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.surfaceAlt,
          ),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Plan')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Transaction Ref')),
            DataColumn(label: Text('Date')),
          ],
          rows: payments.map((tx) {
            return DataRow(cells: [
              DataCell(Text('#${tx.id}')),
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tx.displayName ?? tx.username,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '@${tx.username}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              )),
              DataCell(_PlanChip(plan: tx.plan)),
              DataCell(Text(_formatAmount(tx.amount))),
              DataCell(Text(tx.method)),
              DataCell(_StatusChip(status: tx.status)),
              DataCell(Text(
                tx.transactionRef ?? '-',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              )),
              DataCell(Text(
                tx.createdAt != null ? dateFormat.format(tx.createdAt!.toLocal()) : '-',
                style: const TextStyle(fontSize: 12),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination(AdminPaymentsResult result) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${result.totalElements} transactions total',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            ),
            Text(
              'Page ${_currentPage + 1} / ${result.totalPages}',
              style: const TextStyle(fontSize: 13),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < result.totalPages - 1
                  ? () => setState(() => _currentPage++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  void _refresh() {
    ref.invalidate(adminPaymentsProvider(_providerKey));
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}d';
  }
}

// ─── Widgets ───

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status.toUpperCase()) {
      'SUCCESS' => (AppColors.statusGreen, 'Success'),
      'PENDING' => (AppColors.statusBlue, 'Pending'),
      'FAILED' => (AppColors.error, 'Failed'),
      'CANCELLED' => (AppColors.textSecondary, 'Cancelled'),
      _ => (AppColors.textSecondary, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.plan});

  final String plan;

  @override
  Widget build(BuildContext context) {
    final isYearly = plan.toUpperCase() == 'YEARLY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isYearly ? Colors.amber : AppColors.primary).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        isYearly ? 'Yearly' : 'Monthly',
        style: TextStyle(
          color: isYearly ? Colors.amber.shade800 : AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Debouncer ───

class _Debouncer {
  _Debouncer({required this.milliseconds});

  final int milliseconds;
  VoidCallback? _action;
  bool _isScheduled = false;

  void run(VoidCallback action) {
    _action = action;
    if (!_isScheduled) {
      _isScheduled = true;
      Future.delayed(Duration(milliseconds: milliseconds), () {
        _isScheduled = false;
        _action?.call();
      });
    }
  }
}
