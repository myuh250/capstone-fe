import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/models/payment.dart';
import 'package:frontend/providers/subscription_providers.dart';
import 'package:frontend/repositories/subscription_repository.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  late MockSubscriptionRepository mockRepo;

  setUp(() {
    mockRepo = MockSubscriptionRepository();
  });

  final sampleSub = SubscriptionInfo(
    id: 1,
    plan: SubscriptionPlan.monthly,
    status: 'ACTIVE',
    startDate: DateTime(2024, 6, 1),
    expiryDate: DateTime(2024, 7, 1),
    autoRenew: true,
  );

  group('ActiveSubscriptionNotifier', () {
    test('load fetches active subscription', () async {
      when(() => mockRepo.getActiveSubscription())
          .thenAnswer((_) async => sampleSub);

      final notifier = ActiveSubscriptionNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state.value, isNotNull);
      expect(notifier.state.value!.plan, SubscriptionPlan.monthly);
    });

    test('load returns null when no subscription', () async {
      when(() => mockRepo.getActiveSubscription())
          .thenAnswer((_) async => null);

      final notifier = ActiveSubscriptionNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state.value, isNull);
    });

    test('load sets error on failure', () async {
      when(() => mockRepo.getActiveSubscription())
          .thenThrow(Exception('Error'));

      final notifier = ActiveSubscriptionNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state, isA<AsyncError>());
    });

    test('setActive updates state directly', () async {
      when(() => mockRepo.getActiveSubscription())
          .thenAnswer((_) async => null);

      final notifier = ActiveSubscriptionNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      notifier.setActive(sampleSub);

      expect(notifier.state.value, sampleSub);
    });

    test('clear sets state to null', () async {
      when(() => mockRepo.getActiveSubscription())
          .thenAnswer((_) async => sampleSub);

      final notifier = ActiveSubscriptionNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      notifier.clear();

      expect(notifier.state.value, isNull);
    });
  });

  group('PaymentHistoryNotifier', () {
    test('load fetches transactions', () async {
      final tx = Transaction(
        id: '1',
        plan: SubscriptionPlan.monthly,
        method: PaymentMethod.vnpay,
        status: PaymentStatus.success,
        amount: 49000,
        createdAt: DateTime(2024, 6, 1),
      );
      when(() => mockRepo.getPaymentHistory())
          .thenAnswer((_) async => [tx]);

      final notifier = PaymentHistoryNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state.value?.length, 1);
      expect(notifier.state.value?.first.amount, 49000);
    });

    test('load sets error on failure', () async {
      when(() => mockRepo.getPaymentHistory())
          .thenThrow(Exception('Error'));

      final notifier = PaymentHistoryNotifier(mockRepo);
      await Future.delayed(Duration.zero);

      expect(notifier.state, isA<AsyncError>());
    });
  });
}
