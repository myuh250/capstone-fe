import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/report.dart';

abstract class ModerationRepository {
  Future<List<Report>> getReports({ReportStatus? status, ReportType? type});
  Future<Report> getReportById(String id);
  Future<void> resolveReport(String id, String resolution);
  Future<void> dismissReport(String id, String reason);
  Future<void> submitReport({
    required String type,
    required String reason,
    String? commentId,
    String? mangaId,
  });
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
    final response = await _apiClient.get('${ApiEndpoints.reports}/$id');
    return Report.fromJson(response.data as Map<String, dynamic>);
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

  @override
  Future<void> submitReport({
    required String type,
    required String reason,
    String? commentId,
    String? mangaId,
  }) async {
    final data = <String, dynamic>{
      'type': type,
      'reason': reason,
    };
    if (commentId != null) data['commentId'] = commentId;
    if (mangaId != null) data['mangaId'] = mangaId;
    await _apiClient.post(ApiEndpoints.reports, data: data);
  }
}
