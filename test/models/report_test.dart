import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/report.dart';

void main() {
  group('ReportStatus', () {
    test('labels are correct', () {
      expect(ReportStatus.pending.label, 'Pending');
      expect(ReportStatus.resolved.label, 'Resolved');
      expect(ReportStatus.dismissed.label, 'Dismissed');
    });
  });

  group('ReportType', () {
    test('labels are correct', () {
      expect(ReportType.comment.label, 'Comment');
      expect(ReportType.manga.label, 'Manga');
      expect(ReportType.user.label, 'User');
    });
  });

  group('ReportReason', () {
    test('labels are correct', () {
      expect(ReportReason.spam.label, 'Spam');
      expect(ReportReason.inappropriate.label, 'Inappropriate Content');
      expect(ReportReason.copyright.label, 'Copyright Violation');
      expect(ReportReason.harassment.label, 'Harassment');
      expect(ReportReason.other.label, 'Other');
    });
  });

  group('Report', () {
    test('fromJson parses full object', () {
      final json = {
        'id': '100',
        'type': 'COMMENT',
        'reason': 'SPAM',
        'reportedBy': 'user1',
        'reportedAt': '2024-06-01T10:00:00.000Z',
        'status': 'PENDING',
        'targetId': 'comment-5',
        'targetTitle': 'Bad comment',
        'description': 'This is spam',
        'aiConfidence': 0.95,
        'aiDetected': true,
      };

      final report = Report.fromJson(json);

      expect(report.id, '100');
      expect(report.type, ReportType.comment);
      expect(report.reason, ReportReason.spam);
      expect(report.reportedBy, 'user1');
      expect(report.status, ReportStatus.pending);
      expect(report.targetId, 'comment-5');
      expect(report.description, 'This is spam');
      expect(report.aiConfidence, 0.95);
      expect(report.aiDetected, true);
    });

    test('fromJson defaults unknown type to comment', () {
      final json = {
        'id': '101',
        'type': 'UNKNOWN',
        'reason': 'OTHER',
        'reportedBy': 'user2',
        'reportedAt': '2024-06-01T00:00:00.000Z',
        'status': 'RESOLVED',
      };

      final report = Report.fromJson(json);

      expect(report.type, ReportType.comment);
      expect(report.reason, ReportReason.other);
      expect(report.status, ReportStatus.resolved);
    });

    test('fromJson handles resolved report', () {
      final json = {
        'id': '102',
        'type': 'COMMENT',
        'reason': 'HARASSMENT',
        'reportedBy': 'user3',
        'reportedAt': '2024-05-01T00:00:00.000Z',
        'status': 'DISMISSED',
        'resolvedBy': 'admin1',
        'resolvedAt': '2024-05-02T00:00:00.000Z',
        'resolution': 'Not a violation',
      };

      final report = Report.fromJson(json);

      expect(report.resolvedBy, 'admin1');
      expect(report.resolvedAt, isNotNull);
      expect(report.resolution, 'Not a violation');
    });

    test('isOverdue returns true for old pending reports', () {
      final report = Report(
        id: '103',
        type: ReportType.comment,
        reason: ReportReason.spam,
        reportedBy: 'user',
        reportedAt: DateTime.now().subtract(const Duration(hours: 72)),
        status: ReportStatus.pending,
      );

      expect(report.isOverdue, true);
    });

    test('isOverdue returns false for recent pending reports', () {
      final report = Report(
        id: '104',
        type: ReportType.comment,
        reason: ReportReason.spam,
        reportedBy: 'user',
        reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: ReportStatus.pending,
      );

      expect(report.isOverdue, false);
    });

    test('isOverdue returns false for resolved reports', () {
      final report = Report(
        id: '105',
        type: ReportType.comment,
        reason: ReportReason.spam,
        reportedBy: 'user',
        reportedAt: DateTime.now().subtract(const Duration(hours: 72)),
        status: ReportStatus.resolved,
      );

      expect(report.isOverdue, false);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Report(
        id: '106',
        type: ReportType.comment,
        reason: ReportReason.spam,
        reportedBy: 'user',
        reportedAt: DateTime(2024, 1, 1),
        status: ReportStatus.pending,
      );

      final updated = original.copyWith(
        status: ReportStatus.resolved,
        resolvedBy: 'admin',
      );

      expect(updated.status, ReportStatus.resolved);
      expect(updated.resolvedBy, 'admin');
      expect(updated.id, '106');
      expect(updated.type, ReportType.comment);
    });
  });
}
