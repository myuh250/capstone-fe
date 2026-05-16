import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/payment.dart';
import '../repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(apiClientProvider));
});

final activeSubscriptionProvider =
    StateNotifierProvider<ActiveSubscriptionNotifier, AsyncValue<SubscriptionInfo?>>((ref) {
  return ActiveSubscriptionNotifier(ref.read(subscriptionRepositoryProvider));
});

class ActiveSubscriptionNotifier extends StateNotifier<AsyncValue<SubscriptionInfo?>> {
  ActiveSubscriptionNotifier(this._repository) : super(const AsyncValue.data(null)) {
    load();
  }

  final SubscriptionRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final sub = await _repository.getActiveSubscription();
      state = AsyncValue.data(sub);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setActive(SubscriptionInfo info) {
    state = AsyncValue.data(info);
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final paymentHistoryProvider =
    StateNotifierProvider<PaymentHistoryNotifier, AsyncValue<List<Transaction>>>((ref) {
  return PaymentHistoryNotifier(ref.read(subscriptionRepositoryProvider));
});

class PaymentHistoryNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  PaymentHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final SubscriptionRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _repository.getPaymentHistory();
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(activeSubscriptionProvider).valueOrNull;
  return sub != null && sub.status == 'ACTIVE';
});
