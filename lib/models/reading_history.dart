class ReadingHistory {
  const ReadingHistory({
    this.id,
    required this.mangaId,
    required this.mangaTitle,
    required this.coverUrl,
    required this.lastChapterId,
    required this.lastChapterNumber,
    required this.lastReadAt,
    this.totalChapters = 0,
    this.chaptersRead = 0,
    this.lastPageRead = 0,
  });

  final String? id;
  final String mangaId;
  final String mangaTitle;
  final String coverUrl;
  final String lastChapterId;
  final double lastChapterNumber;
  final DateTime lastReadAt;
  final int totalChapters;
  final int chaptersRead;
  final int lastPageRead;

  double get progressPercent {
    if (totalChapters == 0) return 0;
    return (chaptersRead / totalChapters).clamp(0.0, 1.0);
  }

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    final dateStr = json['lastReadAt'] ?? json['lastReadTime'];
    return ReadingHistory(
      id: json['id']?.toString(),
      mangaId: json['mangaId']?.toString() ?? '',
      mangaTitle: json['mangaTitle'] as String? ?? '',
      coverUrl: (json['coverUrl'] ?? json['mangaCoverUrl']) as String? ?? '',
      lastChapterId: (json['lastChapterId'] ?? json['chapterId'])?.toString() ?? '',
      lastChapterNumber: ((json['lastChapterNumber'] ?? json['chapterNumber']) as num?)?.toDouble() ?? 0,
      lastReadAt: dateStr != null
          ? _parseUtcDate(dateStr as String)
          : DateTime.now(),
      totalChapters: json['totalChapters'] as int? ?? 0,
      chaptersRead: json['chaptersRead'] as int? ?? 0,
      lastPageRead: json['lastPageRead'] as int? ?? 0,
    );
  }

  ReadingHistory copyWith({
    String? id,
    String? mangaId,
    String? mangaTitle,
    String? coverUrl,
    String? lastChapterId,
    double? lastChapterNumber,
    DateTime? lastReadAt,
    int? totalChapters,
    int? chaptersRead,
    int? lastPageRead,
  }) {
    return ReadingHistory(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      coverUrl: coverUrl ?? this.coverUrl,
      lastChapterId: lastChapterId ?? this.lastChapterId,
      lastChapterNumber: lastChapterNumber ?? this.lastChapterNumber,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      totalChapters: totalChapters ?? this.totalChapters,
      chaptersRead: chaptersRead ?? this.chaptersRead,
      lastPageRead: lastPageRead ?? this.lastPageRead,
    );
  }

  static DateTime _parseUtcDate(String dateStr) {
    final parsed = DateTime.parse(dateStr);
    if (parsed.isUtc) return parsed.toLocal();
    return DateTime.utc(
      parsed.year, parsed.month, parsed.day,
      parsed.hour, parsed.minute, parsed.second, parsed.millisecond,
    ).toLocal();
  }
}
