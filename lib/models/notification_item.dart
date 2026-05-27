NotificationType _parseNotificationType(String? value) {
  if (value == null) return NotificationType.system;
  return switch (value.toUpperCase()) {
    'NEW_CHAPTER' => NotificationType.newChapter,
    'COMMENT_REPLY' => NotificationType.commentReply,
    'MENTION' => NotificationType.mention,
    'SUBSCRIPTION' => NotificationType.subscription,
    _ => NotificationType.system,
  };
}

enum NotificationType {
  newChapter,
  commentReply,
  mention,
  system,
  subscription,
}

extension NotificationTypeExtension on NotificationType {
  String get label => switch (this) {
        NotificationType.newChapter => 'New Chapter',
        NotificationType.commentReply => 'Comment Reply',
        NotificationType.mention => 'Mention',
        NotificationType.system => 'System',
        NotificationType.subscription => 'Subscription',
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
      type: _parseNotificationType(json['type'] as String?),
      title: json['title'] as String,
      body: (json['body'] ?? json['message'] ?? '') as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: (json['isRead'] ?? json['read']) as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      targetId: (json['targetId'] ?? json['targetUrl'])?.toString(),
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
