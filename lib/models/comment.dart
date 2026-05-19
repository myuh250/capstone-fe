class Comment {
  const Comment({
    required this.id,
    required this.mangaId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
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
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentId;
  final List<Comment> replies;
  final bool isEdited;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      mangaId: json['mangaId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] as String? ?? json['userDisplayName'] as String? ?? '',
      userAvatarUrl: json['userAvatarUrl'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      parentId: json['parentId']?.toString(),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isEdited: json['isEdited'] as bool? ?? false,
    );
  }

  Comment copyWith({
    String? id,
    String? mangaId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
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
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
