class ReadingHistory {
  const ReadingHistory({
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
    return ReadingHistory(
      mangaId: json['mangaId']?.toString() ?? '',
      mangaTitle: json['mangaTitle'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      lastChapterId: json['lastChapterId']?.toString() ?? '',
      lastChapterNumber: (json['lastChapterNumber'] as num?)?.toDouble() ?? 0,
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.parse(json['lastReadAt'] as String)
          : DateTime.now(),
      totalChapters: json['totalChapters'] as int? ?? 0,
      chaptersRead: json['chaptersRead'] as int? ?? 0,
      lastPageRead: json['lastPageRead'] as int? ?? 0,
    );
  }

  ReadingHistory copyWith({
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
}
