// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MangaImpl _$$MangaImplFromJson(Map<String, dynamic> json) => _$MangaImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String?,
  description: json['description'] as String?,
  coverUrl: json['coverUrl'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  status:
      $enumDecodeNullable(_$MangaStatusEnumMap, json['status']) ??
      MangaStatus.ongoing,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  totalChapters: (json['totalChapters'] as num?)?.toInt() ?? 0,
  author: json['author'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$MangaImplToJson(_$MangaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'coverUrl': instance.coverUrl,
      'tags': instance.tags,
      'status': _$MangaStatusEnumMap[instance.status]!,
      'averageRating': instance.averageRating,
      'totalChapters': instance.totalChapters,
      'author': instance.author,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MangaStatusEnumMap = {
  MangaStatus.ongoing: 'ONGOING',
  MangaStatus.completed: 'COMPLETED',
  MangaStatus.hiatus: 'HIATUS',
  MangaStatus.cancelled: 'CANCELLED',
};
