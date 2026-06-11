enum PaymentMethod { vnpay }

extension PaymentMethodExtension on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.vnpay => 'VNPAY',
      };

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentMethod.vnpay,
    );
  }
}

enum PaymentStatus { pending, success, failed, cancelled }

extension PaymentStatusExtension on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => 'Processing',
        PaymentStatus.success => 'Success',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.cancelled => 'Cancelled',
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
        SubscriptionPlan.monthly => 'Monthly',
        SubscriptionPlan.yearly => 'Yearly',
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
        SubscriptionPlan.yearly => 'Save 32%',
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
    final planStr = json['planName'] as String? ?? json['plan'] as String? ?? 'monthly';
    return Transaction(
      id: json['id'].toString(),
      plan: SubscriptionPlanExtension.fromString(planStr),
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
    final planStr = json['planName'] as String? ?? json['plan'] as String? ?? 'monthly';
    return SubscriptionInfo(
      id: json['id'] as int,
      plan: SubscriptionPlanExtension.fromString(planStr),
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      autoRenew: json['autoRenew'] as bool? ?? false,
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
    this.redirectUrl,
  });

  final int id;
  final SubscriptionPlan plan;
  final PaymentMethod method;
  final PaymentStatus status;
  final int amount;
  final String transactionRef;
  final DateTime createdAt;
  final String? redirectUrl;

  bool get isSuccess => status == PaymentStatus.success;
  bool get requiresRedirect => redirectUrl != null && redirectUrl!.isNotEmpty;

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    final planStr = json['planName'] as String? ?? json['plan'] as String? ?? 'monthly';
    return PaymentResult(
      id: json['id'] as int? ?? 0,
      plan: SubscriptionPlanExtension.fromString(planStr),
      method: PaymentMethodExtension.fromString(json['method'] as String),
      status: PaymentStatusExtension.fromString(json['status'] as String),
      amount: json['amount'] as int,
      transactionRef: json['transactionRef'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      redirectUrl: json['redirectUrl'] as String?,
    );
  }
}
