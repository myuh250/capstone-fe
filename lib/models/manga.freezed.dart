// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Manga _$MangaFromJson(Map<String, dynamic> json) {
  return _Manga.fromJson(json);
}

/// @nodoc
mixin _$Manga {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get coverUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  MangaStatus get status => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get totalChapters => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get hasEarlyAccess => throw _privateConstructorUsedError;

  /// Serializes this Manga to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MangaCopyWith<Manga> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaCopyWith<$Res> {
  factory $MangaCopyWith(Manga value, $Res Function(Manga) then) =
      _$MangaCopyWithImpl<$Res, Manga>;
  @useResult
  $Res call({
    String id,
    String title,
    String? slug,
    String? description,
    String coverUrl,
    List<String> tags,
    MangaStatus status,
    double averageRating,
    int totalChapters,
    String? author,
    DateTime? updatedAt,
    bool hasEarlyAccess,
  });
}

/// @nodoc
class _$MangaCopyWithImpl<$Res, $Val extends Manga>
    implements $MangaCopyWith<$Res> {
  _$MangaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = freezed,
    Object? description = freezed,
    Object? coverUrl = null,
    Object? tags = null,
    Object? status = null,
    Object? averageRating = null,
    Object? totalChapters = null,
    Object? author = freezed,
    Object? updatedAt = freezed,
    Object? hasEarlyAccess = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: freezed == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverUrl: null == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MangaStatus,
            averageRating: null == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double,
            totalChapters: null == totalChapters
                ? _value.totalChapters
                : totalChapters // ignore: cast_nullable_to_non_nullable
                      as int,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            hasEarlyAccess: null == hasEarlyAccess
                ? _value.hasEarlyAccess
                : hasEarlyAccess // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MangaImplCopyWith<$Res> implements $MangaCopyWith<$Res> {
  factory _$$MangaImplCopyWith(
    _$MangaImpl value,
    $Res Function(_$MangaImpl) then,
  ) = __$$MangaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? slug,
    String? description,
    String coverUrl,
    List<String> tags,
    MangaStatus status,
    double averageRating,
    int totalChapters,
    String? author,
    DateTime? updatedAt,
    bool hasEarlyAccess,
  });
}

/// @nodoc
class __$$MangaImplCopyWithImpl<$Res>
    extends _$MangaCopyWithImpl<$Res, _$MangaImpl>
    implements _$$MangaImplCopyWith<$Res> {
  __$$MangaImplCopyWithImpl(
    _$MangaImpl _value,
    $Res Function(_$MangaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = freezed,
    Object? description = freezed,
    Object? coverUrl = null,
    Object? tags = null,
    Object? status = null,
    Object? averageRating = null,
    Object? totalChapters = null,
    Object? author = freezed,
    Object? updatedAt = freezed,
    Object? hasEarlyAccess = null,
  }) {
    return _then(
      _$MangaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: freezed == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverUrl: null == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MangaStatus,
        averageRating: null == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double,
        totalChapters: null == totalChapters
            ? _value.totalChapters
            : totalChapters // ignore: cast_nullable_to_non_nullable
                  as int,
        author: freezed == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        hasEarlyAccess: null == hasEarlyAccess
            ? _value.hasEarlyAccess
            : hasEarlyAccess // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MangaImpl implements _Manga {
  const _$MangaImpl({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    required this.coverUrl,
    final List<String> tags = const [],
    this.status = MangaStatus.ongoing,
    this.averageRating = 0.0,
    this.totalChapters = 0,
    this.author,
    this.updatedAt,
    this.hasEarlyAccess = false,
  }) : _tags = tags;

  factory _$MangaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MangaImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? slug;
  @override
  final String? description;
  @override
  final String coverUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final MangaStatus status;
  @override
  @JsonKey()
  final double averageRating;
  @override
  @JsonKey()
  final int totalChapters;
  @override
  final String? author;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool hasEarlyAccess;

  @override
  String toString() {
    return 'Manga(id: $id, title: $title, slug: $slug, description: $description, coverUrl: $coverUrl, tags: $tags, status: $status, averageRating: $averageRating, totalChapters: $totalChapters, author: $author, updatedAt: $updatedAt, hasEarlyAccess: $hasEarlyAccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalChapters, totalChapters) ||
                other.totalChapters == totalChapters) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.hasEarlyAccess, hasEarlyAccess) ||
                other.hasEarlyAccess == hasEarlyAccess));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    slug,
    description,
    coverUrl,
    const DeepCollectionEquality().hash(_tags),
    status,
    averageRating,
    totalChapters,
    author,
    updatedAt,
    hasEarlyAccess,
  );

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MangaImplCopyWith<_$MangaImpl> get copyWith =>
      __$$MangaImplCopyWithImpl<_$MangaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MangaImplToJson(this);
  }
}

abstract class _Manga implements Manga {
  const factory _Manga({
    required final String id,
    required final String title,
    final String? slug,
    final String? description,
    required final String coverUrl,
    final List<String> tags,
    final MangaStatus status,
    final double averageRating,
    final int totalChapters,
    final String? author,
    final DateTime? updatedAt,
    final bool hasEarlyAccess,
  }) = _$MangaImpl;

  factory _Manga.fromJson(Map<String, dynamic> json) = _$MangaImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get slug;
  @override
  String? get description;
  @override
  String get coverUrl;
  @override
  List<String> get tags;
  @override
  MangaStatus get status;
  @override
  double get averageRating;
  @override
  int get totalChapters;
  @override
  String? get author;
  @override
  DateTime? get updatedAt;
  @override
  bool get hasEarlyAccess;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MangaImplCopyWith<_$MangaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
