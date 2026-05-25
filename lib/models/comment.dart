class Comment {
  const Comment({
    required this.id,
    required this.mangaId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.isUserPremium = false,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.parentId,
    this.replies = const [],
    this.isEdited = false,
  });

  final String id;
  final String mangaId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final bool isUserPremium;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentId;
  final List<Comment> replies;
  final bool isEdited;

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final manga = json['manga'] as Map<String, dynamic>?;

    return Comment(
      id: json['id'].toString(),
      mangaId: manga?['id']?.toString() ?? json['mangaId']?.toString() ?? '',
      userId: user?['id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: user?['displayName'] as String? ??
          user?['username'] as String? ??
          json['userName'] as String? ??
          '',
      userAvatarUrl: user?['avatarUrl'] as String? ?? json['userAvatarUrl'] as String?,
      isUserPremium: user?['isPremium'] as bool? ?? false,
      content: json['content'] as String,
      createdAt: _parseUtc(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? _parseUtc(json['updatedAt'] as String)
          : null,
      parentId: json['parentId']?.toString(),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isEdited: json['edited'] as bool? ?? json['isEdited'] as bool? ?? false,
    );
  }

  static DateTime _parseUtc(String value) {
    final dt = DateTime.parse(value);
    return dt.isUtc ? dt : DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond);
  }

  Comment copyWith({
    String? id,
    String? mangaId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    bool? isUserPremium,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    List<Comment>? replies,
    bool? isEdited,
  }) {
    return Comment(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      isUserPremium: isUserPremium ?? this.isUserPremium,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
