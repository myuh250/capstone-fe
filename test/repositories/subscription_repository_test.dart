import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/models/payment.dart';
import 'package:frontend/repositories/subscription_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late SubscriptionRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = SubscriptionRepository(mockApiClient);
  });

  group('SubscriptionRepository', () {
    group('getActiveSubscription()', () {
      test('returns subscription info', () async {
        when(() => mockApiClient.get('${ApiEndpoints.subscriptions}/me'))
            .thenAnswer((_) async => Response(
                  data: {
                    'id': 1,
                    'plan': 'MONTHLY',
                    'status': 'ACTIVE',
                    'startDate': '2024-06-01T00:00:00.000Z',
                    'expiryDate': '2024-07-01T00:00:00.000Z',
                    'autoRenew': true,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getActiveSubscription();

        expect(result, isNotNull);
        expect(result!.plan, SubscriptionPlan.monthly);
        expect(result.status, 'ACTIVE');
        expect(result.autoRenew, true);
      });

      test('returns null when no active subscription', () async {
        when(() => mockApiClient.get('${ApiEndpoints.subscriptions}/me'))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.getActiveSubscription();

        expect(result, isNull);
      });
    });

    group('createPayment()', () {
      test('returns payment result with redirect URL', () async {
        when(() => mockApiClient.post(
              '${ApiEndpoints.subscriptions}/payment',
              data: {'plan': 'MONTHLY', 'method': 'VNPAY'},
            )).thenAnswer((_) async => Response(
              data: {
                'id': 10,
                'plan': 'MONTHLY',
                'method': 'VNPAY',
                'status': 'PENDING',
                'amount': 49000,
                'transactionRef': 'VNP-123',
                'createdAt': '2024-06-01T10:00:00.000Z',
                'redirectUrl': 'https://vnpay.vn/pay?ref=123',
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.createPayment(
          plan: SubscriptionPlan.monthly,
          method: PaymentMethod.vnpay,
        );

        expect(result.amount, 49000);
        expect(result.redirectUrl, 'https://vnpay.vn/pay?ref=123');
        expect(result.requiresRedirect, true);
        expect(result.status, PaymentStatus.pending);
      });
    });

    group('cancelSubscription()', () {
      test('returns updated subscription info', () async {
        when(() => mockApiClient.post('${ApiEndpoints.subscriptions}/cancel'))
            .thenAnswer((_) async => Response(
                  data: {
                    'id': 1,
                    'plan': 'MONTHLY',
                    'status': 'ACTIVE',
                    'startDate': '2024-06-01T00:00:00.000Z',
                    'expiryDate': '2024-07-01T00:00:00.000Z',
                    'autoRenew': false,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        final result = await repository.cancelSubscription();

        expect(result.autoRenew, false);
      });
    });

    group('getPaymentHistory()', () {
      test('returns list of transactions', () async {
        when(() => mockApiClient.get(
              '${ApiEndpoints.subscriptions}/payments',
              queryParameters: {'page': 0, 'size': 20},
            )).thenAnswer((_) async => Response(
              data: {
                'content': [
                  {
                    'id': 1,
                    'plan': 'MONTHLY',
                    'method': 'VNPAY',
                    'status': 'SUCCESS',
                    'amount': 49000,
                    'createdAt': '2024-06-01T10:00:00.000Z',
                  },
                  {
                    'id': 2,
                    'plan': 'YEARLY',
                    'method': 'VNPAY',
                    'status': 'FAILED',
                    'amount': 399000,
                    'createdAt': '2024-05-01T10:00:00.000Z',
                  },
                ]
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.getPaymentHistory();

        expect(result.length, 2);
        expect(result.first.status, PaymentStatus.success);
        expect(result.last.status, PaymentStatus.failed);
        expect(result.last.plan, SubscriptionPlan.yearly);
      });
    });
  });
}
