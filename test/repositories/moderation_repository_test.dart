import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/models/report.dart';
import 'package:frontend/repositories/moderation_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late RealModerationRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = RealModerationRepository(mockApiClient);
  });

  final sampleReportJson = {
    'id': '1',
    'type': 'COMMENT',
    'reason': 'SPAM',
    'reportedBy': 'user1',
    'reportedAt': '2024-06-01T10:00:00.000Z',
    'status': 'PENDING',
  };

  group('ModerationRepository', () {
    group('getReports()', () {
      test('returns list from array response', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.reports,
              queryParameters: {},
            )).thenAnswer((_) async => Response(
              data: [sampleReportJson],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.getReports();

        expect(result.length, 1);
        expect(result.first.type, ReportType.comment);
      });

      test('filters by status', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.reports,
              queryParameters: {'status': 'PENDING'},
            )).thenAnswer((_) async => Response(
              data: [sampleReportJson],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.getReports(status: ReportStatus.pending);

        expect(result.length, 1);
      });

      test('filters by type client-side', () async {
        final reports = [
          sampleReportJson,
          {
            'id': '2',
            'type': 'MANGA',
            'reason': 'COPYRIGHT',
            'reportedBy': 'user2',
            'reportedAt': '2024-06-02T10:00:00.000Z',
            'status': 'PENDING',
          },
        ];

        when(() => mockApiClient.get(
              ApiEndpoints.reports,
              queryParameters: {},
            )).thenAnswer((_) async => Response(
              data: reports,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.getReports(type: ReportType.manga);

        expect(result.length, 1);
        expect(result.first.type, ReportType.manga);
      });

      test('handles paginated response', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.reports,
              queryParameters: {},
            )).thenAnswer((_) async => Response(
              data: {'content': [sampleReportJson]},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.getReports();

        expect(result.length, 1);
      });
    });

    group('getReportById()', () {
      test('returns matching report', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.reports,
              queryParameters: {},
            )).thenAnswer((_) async => Response(
              data: [sampleReportJson],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.getReportById('1');

        expect(result.id, '1');
      });
    });

    group('resolveReport()', () {
      test('calls put with resolve action', () async {
        when(() => mockApiClient.put(
              ApiEndpoints.reportReview('1'),
              data: {'action': 'RESOLVE', 'resolution': 'Confirmed spam'},
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        await repository.resolveReport('1', 'Confirmed spam');

        verify(() => mockApiClient.put(
              ApiEndpoints.reportReview('1'),
              data: {'action': 'RESOLVE', 'resolution': 'Confirmed spam'},
            )).called(1);
      });
    });

    group('dismissReport()', () {
      test('calls put with dismiss action', () async {
        when(() => mockApiClient.put(
              ApiEndpoints.reportReview('1'),
              data: {'action': 'DISMISS', 'resolution': 'Not a violation'},
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        await repository.dismissReport('1', 'Not a violation');

        verify(() => mockApiClient.put(
              ApiEndpoints.reportReview('1'),
              data: {'action': 'DISMISS', 'resolution': 'Not a violation'},
            )).called(1);
      });
    });
  });
}
