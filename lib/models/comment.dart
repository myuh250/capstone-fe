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
