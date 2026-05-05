class Chapter {
  const Chapter({
    required this.id,
    required this.mangaId,
    required this.number,
    this.title,
    this.pageCount = 0,
    this.isRead = false,
    this.isEarlyAccess = false,
    this.publishedAt,
  });

  final String id;
  final String mangaId;
  final double number;
  final String? title;
  final int pageCount;
  final bool isRead;
  final bool isEarlyAccess;
  final DateTime? publishedAt;

  String get displayNumber {
    if (number == number.truncate()) {
      return 'Ch.${number.toInt()}';
    }
    return 'Ch.$number';
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      mangaId: json['mangaId'] as String,
      number: (json['number'] as num).toDouble(),
      title: json['title'] as String?,
      pageCount: json['pageCount'] as int? ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      isEarlyAccess: json['isEarlyAccess'] as bool? ?? false,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mangaId': mangaId,
        'number': number,
        'title': title,
        'pageCount': pageCount,
        'isRead': isRead,
        'isEarlyAccess': isEarlyAccess,
        'publishedAt': publishedAt?.toIso8601String(),
      };

  Chapter copyWith({
    String? id,
    String? mangaId,
    double? number,
    String? title,
    int? pageCount,
    bool? isRead,
    bool? isEarlyAccess,
    DateTime? publishedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      number: number ?? this.number,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
      isRead: isRead ?? this.isRead,
      isEarlyAccess: isEarlyAccess ?? this.isEarlyAccess,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
