enum ReportStatus {
  pending,
  resolved,
  dismissed,
}

extension ReportStatusExtension on ReportStatus {
  String get label => switch (this) {
        ReportStatus.pending => 'Pending',
        ReportStatus.resolved => 'Resolved',
        ReportStatus.dismissed => 'Dismissed',
      };
}

enum ReportType {
  comment,
  manga,
  user,
}

extension ReportTypeExtension on ReportType {
  String get label => switch (this) {
        ReportType.comment => 'Comment',
        ReportType.manga => 'Manga',
        ReportType.user => 'User',
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
        ReportReason.inappropriate => 'Inappropriate Content',
        ReportReason.copyright => 'Copyright Violation',
        ReportReason.harassment => 'Harassment',
        ReportReason.other => 'Other',
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

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      type: ReportType.values.firstWhere(
        (t) => t.name == (json['type'] as String?)?.toLowerCase(),
        orElse: () => ReportType.comment,
      ),
      reason: ReportReason.values.firstWhere(
        (r) => r.name == (json['reason'] as String?)?.toLowerCase(),
        orElse: () => ReportReason.other,
      ),
      reportedBy: json['reportedBy']?.toString() ?? '',
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?)?.toLowerCase(),
        orElse: () => ReportStatus.pending,
      ),
      targetId: json['targetId']?.toString(),
      targetTitle: json['targetTitle'] as String?,
      description: json['description'] as String?,
      resolvedBy: json['resolvedBy']?.toString(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'] as String)
          : null,
      resolution: json['resolution'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      aiDetected: json['aiDetected'] as bool? ?? false,
    );
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
