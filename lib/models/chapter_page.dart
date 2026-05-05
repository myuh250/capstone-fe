class ChapterPage {
  const ChapterPage({
    required this.id,
    required this.chapterId,
    required this.pageNumber,
    required this.imageUrl,
    this.width,
    this.height,
  });

  final String id;
  final String chapterId;
  final int pageNumber;
  final String imageUrl;
  final int? width;
  final int? height;

  factory ChapterPage.fromJson(Map<String, dynamic> json) {
    return ChapterPage(
      id: json['id'] as String,
      chapterId: json['chapterId'] as String,
      pageNumber: json['pageNumber'] as int,
      imageUrl: json['imageUrl'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }
}
