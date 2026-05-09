import '../models/report.dart';

abstract class ModerationRepository {
  Future<List<Report>> getReports({ReportStatus? status, ReportType? type});
  Future<Report> getReportById(String id);
  Future<void> resolveReport(String id, String resolution);
  Future<void> dismissReport(String id, String reason);
}

class FakeModerationRepository implements ModerationRepository {
  final List<Report> _reports = [
    Report(
      id: 'r001',
      type: ReportType.comment,
      reason: ReportReason.spam,
      reportedBy: 'user123',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: ReportStatus.pending,
      targetId: 'comment_456',
      targetTitle: '"Bộ này không hay, toàn spam link kiếm tiền..."',
      aiDetected: true,
      aiConfidence: 0.92,
    ),
    Report(
      id: 'r002',
      type: ReportType.comment,
      reason: ReportReason.harassment,
      reportedBy: 'user456',
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
      status: ReportStatus.pending,
      targetId: 'comment_789',
      targetTitle: '"Tác giả vẽ xấu, không biết vẽ thì đừng có làm..."',
      description: 'Bình luận này xúc phạm tác giả manga một cách thô lỗ.',
      aiDetected: true,
      aiConfidence: 0.74,
    ),
    Report(
      id: 'r003',
      type: ReportType.manga,
      reason: ReportReason.copyright,
      reportedBy: 'user789',
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: ReportStatus.pending,
      targetId: 'manga_123',
      targetTitle: 'Detective Conan Fan Scan',
      description: 'Manga này đăng bản scan không có bản quyền.',
      aiDetected: false,
    ),
    Report(
      id: 'r004',
      type: ReportType.comment,
      reason: ReportReason.inappropriate,
      reportedBy: 'user321',
      reportedAt: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
      status: ReportStatus.pending,
      targetId: 'comment_101',
      targetTitle: '"Nội dung người lớn trong chapter này..."',
    ),
    Report(
      id: 'r005',
      type: ReportType.user,
      reason: ReportReason.spam,
      reportedBy: 'user654',
      reportedAt: DateTime.now().subtract(const Duration(days: 3)),
      status: ReportStatus.resolved,
      targetId: 'user_999',
      targetTitle: 'spammer2024',
      resolvedBy: 'admin01',
      resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
      resolution: 'Đã ban tài khoản spam vĩnh viễn.',
    ),
    Report(
      id: 'r006',
      type: ReportType.comment,
      reason: ReportReason.other,
      reportedBy: 'user111',
      reportedAt: DateTime.now().subtract(const Duration(days: 4)),
      status: ReportStatus.dismissed,
      targetId: 'comment_222',
      targetTitle: '"Tôi không thích arc này lắm..."',
      resolvedBy: 'admin01',
      resolvedAt: DateTime.now().subtract(const Duration(days: 3)),
      resolution: 'Không vi phạm nội quy cộng đồng.',
    ),
    Report(
      id: 'r007',
      type: ReportType.manga,
      reason: ReportReason.inappropriate,
      reportedBy: 'user222',
      reportedAt: DateTime.now().subtract(const Duration(days: 60)),
      status: ReportStatus.pending,
      targetId: 'manga_456',
      targetTitle: 'Manga X (NSFW covers)',
      description: 'Ảnh bìa chứa nội dung không phù hợp với lứa tuổi.',
    ),
  ];

  @override
  Future<List<Report>> getReports({
    ReportStatus? status,
    ReportType? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var results = List<Report>.from(_reports);
    if (status != null) {
      results = results.where((r) => r.status == status).toList();
    }
    if (type != null) {
      results = results.where((r) => r.type == type).toList();
    }
    results.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return results;
  }

  @override
  Future<Report> getReportById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _reports.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> resolveReport(String id, String resolution) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _reports[idx] = _reports[idx].copyWith(
        status: ReportStatus.resolved,
        resolvedBy: 'admin01',
        resolvedAt: DateTime.now(),
        resolution: resolution,
      );
    }
  }

  @override
  Future<void> dismissReport(String id, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _reports[idx] = _reports[idx].copyWith(
        status: ReportStatus.dismissed,
        resolvedBy: 'admin01',
        resolvedAt: DateTime.now(),
        resolution: reason,
      );
    }
  }
}
