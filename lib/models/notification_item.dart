enum NotificationType {
  newChapter,
  commentReply,
  system,
  subscription,
}

extension NotificationTypeExtension on NotificationType {
  String get label => switch (this) {
        NotificationType.newChapter => 'Chương mới',
        NotificationType.commentReply => 'Phản hồi bình luận',
        NotificationType.system => 'Hệ thống',
        NotificationType.subscription => 'Gói dịch vụ',
      };
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.targetId,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? targetId;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(),
      type: NotificationType.values.firstWhere(
        (t) => t.name == (json['type'] as String?)?.toLowerCase(),
        orElse: () => NotificationType.system,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      targetId: json['targetId']?.toString(),
    );
  }

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? targetId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      targetId: targetId ?? this.targetId,
    );
  }
}
