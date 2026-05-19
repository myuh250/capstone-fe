import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/report.dart';

abstract class ModerationRepository {
  Future<List<Report>> getReports({ReportStatus? status, ReportType? type});
  Future<Report> getReportById(String id);
  Future<void> resolveReport(String id, String resolution);
  Future<void> dismissReport(String id, String reason);
}

class RealModerationRepository implements ModerationRepository {
  RealModerationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Report>> getReports({
    ReportStatus? status,
    ReportType? type,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status.name.toUpperCase();

    final response = await _apiClient.get(
      ApiEndpoints.reports,
      queryParameters: params,
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    var reports = list
        .map((e) => Report.fromJson(e as Map<String, dynamic>))
        .toList();

    // Client-side filter by type since BE doesn't support it as a query param
    if (type != null) {
      reports = reports.where((r) => r.type == type).toList();
    }

    reports.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return reports;
  }

  @override
  Future<Report> getReportById(String id) async {
    // BE doesn't have GET /reports/{id}; load from list and find
    final all = await getReports();
    return all.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> resolveReport(String id, String resolution) async {
    await _apiClient.put(
      ApiEndpoints.reportReview(id),
      data: {'action': 'RESOLVE', 'resolution': resolution},
    );
  }

  @override
  Future<void> dismissReport(String id, String reason) async {
    await _apiClient.put(
      ApiEndpoints.reportReview(id),
      data: {'action': 'DISMISS', 'resolution': reason},
    );
  }
}
