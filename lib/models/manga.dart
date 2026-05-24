import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga.freezed.dart';
part 'manga.g.dart';

@freezed
class Manga with _$Manga {
  const factory Manga({
    required String id,
    required String title,
    String? slug,
    String? description,
    required String coverUrl,
    @Default([]) List<String> tags,
    @Default(MangaStatus.ongoing) MangaStatus status,
    @Default(0.0) double averageRating,
    @Default(0) int totalChapters,
    String? author,
    DateTime? updatedAt,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

enum MangaStatus {
  @JsonValue('ONGOING')
  ongoing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('HIATUS')
  hiatus,
  @JsonValue('CANCELLED')
  cancelled,
}

extension MangaStatusExtension on MangaStatus {
  String get displayName {
    return switch (this) {
      MangaStatus.ongoing => 'Ongoing',
      MangaStatus.completed => 'Completed',
      MangaStatus.hiatus => 'Hiatus',
      MangaStatus.cancelled => 'Cancelled',
    };
  }
}
