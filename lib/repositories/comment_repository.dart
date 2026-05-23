import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/comment.dart';

class RatingStats {
  const RatingStats({required this.averageScore, required this.ratingCount});
  final double averageScore;
  final int ratingCount;
}

abstract class CommentRepository {
  Future<List<Comment>> getComments(String mangaId, {int page = 0});
  Future<Comment> addComment(String mangaId, String content, {String? parentId});
  Future<void> editComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<int?> getUserRating(String mangaId);
  Future<RatingStats> ratemanga(String mangaId, int rating);
  Future<RatingStats> getRatingStats(String mangaId);
}

class RealCommentRepository implements CommentRepository {
  RealCommentRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Comment>> getComments(String mangaId, {int page = 0}) async {
    final response = await _apiClient.get(
      ApiEndpoints.commentsByManga(mangaId),
      queryParameters: {'page': page},
    );
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else {
      list = (data as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
    }
    return list
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Comment> addComment(
    String mangaId,
    String content, {
    String? parentId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.commentsCreate,
      data: {
        'mangaId': mangaId,
        'content': content,
        if (parentId != null) 'parentId': parentId,
      },
    );
    return Comment.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> editComment(String commentId, String content) async {
    await _apiClient.put(
      ApiEndpoints.commentUpdate(commentId),
      data: {'content': content},
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _apiClient.delete(ApiEndpoints.commentDelete(commentId));
  }

  @override
  Future<int?> getUserRating(String mangaId) async {
    try {
      final response = await _apiClient.get(
        '/ratings/me',
        queryParameters: {'mangaId': mangaId},
      );
      final data = response.data;
      if (data == null) return null;
      if (data is Map<String, dynamic>) {
        return data['score'] as int?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RatingStats> ratemanga(String mangaId, int rating) async {
    final response = await _apiClient.post(
      ApiEndpoints.ratingsCreate,
      data: {'mangaId': mangaId, 'score': rating},
    );
    final data = response.data as Map<String, dynamic>;
    return RatingStats(
      averageScore: (data['averageScore'] as num).toDouble(),
      ratingCount: (data['ratingCount'] as num).toInt(),
    );
  }

  @override
  Future<RatingStats> getRatingStats(String mangaId) async {
    final response = await _apiClient.get(
      ApiEndpoints.mangaAverageRating(mangaId),
    );
    final data = response.data as Map<String, dynamic>;
    return RatingStats(
      averageScore: (data['averageScore'] as num).toDouble(),
      ratingCount: (data['ratingCount'] as num).toInt(),
    );
  }
}
