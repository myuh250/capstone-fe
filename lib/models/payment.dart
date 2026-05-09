enum PaymentMethod { momo, vnpay }

extension PaymentMethodExtension on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.momo => 'MoMo',
        PaymentMethod.vnpay => 'VNPAY',
      };
}

enum PaymentStatus { pending, success, failed, cancelled }

extension PaymentStatusExtension on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => 'Đang xử lý',
        PaymentStatus.success => 'Thành công',
        PaymentStatus.failed => 'Thất bại',
        PaymentStatus.cancelled => 'Đã hủy',
      };
}

enum SubscriptionPlan { monthly, yearly }

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get label => switch (this) {
        SubscriptionPlan.monthly => 'Hàng tháng',
        SubscriptionPlan.yearly => 'Hàng năm',
      };

  int get priceVnd => switch (this) {
        SubscriptionPlan.monthly => 49000,
        SubscriptionPlan.yearly => 399000,
      };

  String get formattedPrice {
    final p = priceVnd;
    return '${formatNumber(p)}đ';
  }

  String get savings => switch (this) {
        SubscriptionPlan.monthly => '',
        SubscriptionPlan.yearly => 'Tiết kiệm 32%',
      };

  static String formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class Transaction {
  const Transaction({
    required this.id,
    required this.plan,
    required this.method,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final SubscriptionPlan plan;
  final PaymentMethod method;
  final PaymentStatus status;
  final int amount;
  final DateTime createdAt;
}
