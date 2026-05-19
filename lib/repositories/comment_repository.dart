import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getComments(String mangaId, {int page = 0});
  Future<Comment> addComment(String mangaId, String content, {String? parentId});
  Future<void> editComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<int?> getUserRating(String mangaId);
  Future<void> ratemanga(String mangaId, int rating);
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
    // Rating lives under /ratings — need userId from current user context
    // Return null if not rated; caller handles via separate rating provider
    try {
      final response = await _apiClient.get(
        ApiEndpoints.ratingsCreate,
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
  Future<void> ratemanga(String mangaId, int rating) async {
    await _apiClient.post(
      ApiEndpoints.ratingsCreate,
      data: {'mangaId': mangaId, 'score': rating},
    );
  }
}
