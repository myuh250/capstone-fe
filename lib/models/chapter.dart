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

  /// Safely parse a date that may come as an ISO string OR a Java LocalDateTime
  /// array [year, month, day, hour, minute, second, nano].
  static DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is List && raw.length >= 3) {
      try {
        return DateTime(
          raw[0] as int,
          raw[1] as int,
          raw[2] as int,
          raw.length > 3 ? raw[3] as int : 0,
          raw.length > 4 ? raw[4] as int : 0,
          raw.length > 5 ? raw[5] as int : 0,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      // backend sends 'mangaId' as a flat column; fall back gracefully if missing
      mangaId: (json['mangaId'] ?? '') as String,
      // backend field is 'chapterNumber', not 'number'
      number: (json['chapterNumber'] as num? ?? json['number'] as num? ?? 0).toDouble(),
      title: json['title'] as String?,
      pageCount: json['pageCount'] as int? ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      // backend field is 'earlyAccess', not 'isEarlyAccess'
      isEarlyAccess: json['earlyAccess'] as bool? ?? json['isEarlyAccess'] as bool? ?? false,
      // backend sends LocalDateTime as ISO string after jackson config fix;
      // guard against the old array format [2024,1,15,...] just in case
      publishedAt: _parseDateTime(json['updatedAt'] ?? json['publishedAt']),
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
