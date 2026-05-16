enum PaymentMethod { momo, vnpay }

extension PaymentMethodExtension on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.momo => 'MoMo',
        PaymentMethod.vnpay => 'VNPAY',
      };

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentMethod.momo,
    );
  }
}

enum PaymentStatus { pending, success, failed, cancelled }

extension PaymentStatusExtension on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => 'Đang xử lý',
        PaymentStatus.success => 'Thành công',
        PaymentStatus.failed => 'Thất bại',
        PaymentStatus.cancelled => 'Đã hủy',
      };

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
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

  static SubscriptionPlan fromString(String value) {
    return SubscriptionPlan.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SubscriptionPlan.monthly,
    );
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      plan: SubscriptionPlanExtension.fromString(json['plan'] as String),
      method: PaymentMethodExtension.fromString(json['method'] as String),
      status: PaymentStatusExtension.fromString(json['status'] as String),
      amount: json['amount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.id,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    required this.autoRenew,
  });

  final int id;
  final SubscriptionPlan plan;
  final String status;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool autoRenew;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: json['id'] as int,
      plan: SubscriptionPlanExtension.fromString(json['plan'] as String),
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      autoRenew: json['autoRenew'] as bool? ?? true,
    );
  }
}

class PaymentResult {
  const PaymentResult({
    required this.id,
    required this.plan,
    required this.method,
    required this.status,
    required this.amount,
    required this.transactionRef,
    required this.createdAt,
  });

  final int id;
  final SubscriptionPlan plan;
  final PaymentMethod method;
  final PaymentStatus status;
  final int amount;
  final String transactionRef;
  final DateTime createdAt;

  bool get isSuccess => status == PaymentStatus.success;

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      id: json['id'] as int,
      plan: SubscriptionPlanExtension.fromString(json['plan'] as String),
      method: PaymentMethodExtension.fromString(json['method'] as String),
      status: PaymentStatusExtension.fromString(json['status'] as String),
      amount: json['amount'] as int,
      transactionRef: json['transactionRef'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
