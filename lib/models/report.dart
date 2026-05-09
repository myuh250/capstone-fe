enum ReportStatus {
  pending,
  resolved,
  dismissed,
}

extension ReportStatusExtension on ReportStatus {
  String get label => switch (this) {
        ReportStatus.pending => 'Chờ xử lý',
        ReportStatus.resolved => 'Đã xử lý',
        ReportStatus.dismissed => 'Đã bỏ qua',
      };
}

enum ReportType {
  comment,
  manga,
  user,
}

extension ReportTypeExtension on ReportType {
  String get label => switch (this) {
        ReportType.comment => 'Bình luận',
        ReportType.manga => 'Manga',
        ReportType.user => 'Người dùng',
      };
}

enum ReportReason {
  spam,
  inappropriate,
  copyright,
  harassment,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get label => switch (this) {
        ReportReason.spam => 'Spam',
        ReportReason.inappropriate => 'Nội dung không phù hợp',
        ReportReason.copyright => 'Vi phạm bản quyền',
        ReportReason.harassment => 'Quấy rối',
        ReportReason.other => 'Khác',
      };
}

class Report {
  const Report({
    required this.id,
    required this.type,
    required this.reason,
    required this.reportedBy,
    required this.reportedAt,
    required this.status,
    this.targetId,
    this.targetTitle,
    this.description,
    this.resolvedBy,
    this.resolvedAt,
    this.resolution,
    this.aiConfidence,
    this.aiDetected = false,
  });

  final String id;
  final ReportType type;
  final ReportReason reason;
  final String reportedBy;
  final DateTime reportedAt;
  final ReportStatus status;
  final String? targetId;
  final String? targetTitle;
  final String? description;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolution;
  final double? aiConfidence;
  final bool aiDetected;

  bool get isOverdue {
    if (status != ReportStatus.pending) return false;
    return DateTime.now().difference(reportedAt).inHours > 48;
  }

  Report copyWith({
    String? id,
    ReportType? type,
    ReportReason? reason,
    String? reportedBy,
    DateTime? reportedAt,
    ReportStatus? status,
    String? targetId,
    String? targetTitle,
    String? description,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? resolution,
    double? aiConfidence,
    bool? aiDetected,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedAt: reportedAt ?? this.reportedAt,
      status: status ?? this.status,
      targetId: targetId ?? this.targetId,
      targetTitle: targetTitle ?? this.targetTitle,
      description: description ?? this.description,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiDetected: aiDetected ?? this.aiDetected,
    );
  }
}
