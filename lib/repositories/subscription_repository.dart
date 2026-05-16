import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/payment.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SubscriptionInfo?> getActiveSubscription() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.subscriptions}/me',
    );
    if (response.data == null) return null;
    return SubscriptionInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentResult> createPayment({
    required SubscriptionPlan plan,
    required PaymentMethod method,
  }) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.subscriptions}/payment',
      data: {
        'plan': plan.name.toUpperCase(),
        'method': method.name.toUpperCase(),
      },
    );
    return PaymentResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SubscriptionInfo> cancelSubscription() async {
    final response = await _apiClient.post(
      '${ApiEndpoints.subscriptions}/cancel',
    );
    return SubscriptionInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Transaction>> getPaymentHistory({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.subscriptions}/payments',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    return content
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
