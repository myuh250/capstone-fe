import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/payment.dart';

void main() {
  group('PaymentMethod', () {
    test('label returns VNPAY', () {
      expect(PaymentMethod.vnpay.label, 'VNPAY');
    });

    test('fromString parses correctly', () {
      expect(PaymentMethodExtension.fromString('VNPAY'), PaymentMethod.vnpay);
      expect(PaymentMethodExtension.fromString('vnpay'), PaymentMethod.vnpay);
    });
  });

  group('PaymentStatus', () {
    test('labels are correct', () {
      expect(PaymentStatus.pending.label, 'Processing');
      expect(PaymentStatus.success.label, 'Success');
      expect(PaymentStatus.failed.label, 'Failed');
      expect(PaymentStatus.cancelled.label, 'Cancelled');
    });

    test('fromString parses correctly', () {
      expect(PaymentStatusExtension.fromString('SUCCESS'), PaymentStatus.success);
      expect(PaymentStatusExtension.fromString('FAILED'), PaymentStatus.failed);
      expect(PaymentStatusExtension.fromString('PENDING'), PaymentStatus.pending);
    });

    test('fromString defaults to pending for unknown', () {
      expect(PaymentStatusExtension.fromString('UNKNOWN'), PaymentStatus.pending);
    });
  });

  group('SubscriptionPlan', () {
    test('labels are correct', () {
      expect(SubscriptionPlan.monthly.label, 'Monthly');
      expect(SubscriptionPlan.yearly.label, 'Yearly');
    });

    test('prices are correct', () {
      expect(SubscriptionPlan.monthly.priceVnd, 49000);
      expect(SubscriptionPlan.yearly.priceVnd, 399000);
    });

    test('formatted price includes separator', () {
      expect(SubscriptionPlan.monthly.formattedPrice, '49.000đ');
      expect(SubscriptionPlan.yearly.formattedPrice, '399.000đ');
    });

    test('savings shows for yearly only', () {
      expect(SubscriptionPlan.monthly.savings, '');
      expect(SubscriptionPlan.yearly.savings, 'Save 32%');
    });

    test('fromString parses correctly', () {
      expect(SubscriptionPlanExtension.fromString('MONTHLY'), SubscriptionPlan.monthly);
      expect(SubscriptionPlanExtension.fromString('YEARLY'), SubscriptionPlan.yearly);
    });
  });

  group('Transaction', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 123,
        'plan': 'MONTHLY',
        'method': 'VNPAY',
        'status': 'SUCCESS',
        'amount': 49000,
        'createdAt': '2024-06-01T10:00:00.000Z',
      };

      final tx = Transaction.fromJson(json);

      expect(tx.id, '123');
      expect(tx.plan, SubscriptionPlan.monthly);
      expect(tx.method, PaymentMethod.vnpay);
      expect(tx.status, PaymentStatus.success);
      expect(tx.amount, 49000);
      expect(tx.createdAt.year, 2024);
    });
  });

  group('SubscriptionInfo', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'plan': 'YEARLY',
        'status': 'ACTIVE',
        'startDate': '2024-01-01T00:00:00.000Z',
        'expiryDate': '2025-01-01T00:00:00.000Z',
        'autoRenew': true,
      };

      final info = SubscriptionInfo.fromJson(json);

      expect(info.id, 1);
      expect(info.plan, SubscriptionPlan.yearly);
      expect(info.status, 'ACTIVE');
      expect(info.autoRenew, true);
    });

    test('defaults autoRenew to true when missing', () {
      final json = {
        'id': 2,
        'plan': 'MONTHLY',
        'status': 'ACTIVE',
        'startDate': '2024-01-01T00:00:00.000Z',
        'expiryDate': '2024-02-01T00:00:00.000Z',
      };

      final info = SubscriptionInfo.fromJson(json);
      expect(info.autoRenew, true);
    });
  });

  group('PaymentResult', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 10,
        'plan': 'MONTHLY',
        'method': 'VNPAY',
        'status': 'PENDING',
        'amount': 49000,
        'transactionRef': 'VNP-123',
        'createdAt': '2024-06-01T10:00:00.000Z',
        'redirectUrl': 'https://vnpay.vn/pay?ref=123',
      };

      final result = PaymentResult.fromJson(json);

      expect(result.id, 10);
      expect(result.plan, SubscriptionPlan.monthly);
      expect(result.status, PaymentStatus.pending);
      expect(result.amount, 49000);
      expect(result.transactionRef, 'VNP-123');
      expect(result.redirectUrl, 'https://vnpay.vn/pay?ref=123');
      expect(result.requiresRedirect, true);
      expect(result.isSuccess, false);
    });

    test('isSuccess returns true for success status', () {
      final json = {
        'id': 11,
        'plan': 'MONTHLY',
        'method': 'VNPAY',
        'status': 'SUCCESS',
        'amount': 49000,
        'transactionRef': 'VNP-456',
        'createdAt': '2024-06-01T10:00:00.000Z',
      };

      final result = PaymentResult.fromJson(json);
      expect(result.isSuccess, true);
      expect(result.requiresRedirect, false);
    });
  });
}
