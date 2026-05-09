import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment.dart';
import '../repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return FakeCommentRepository();
});

final commentsProvider =
    StateNotifierProvider.family<CommentsNotifier, CommentsState, String>(
  (ref, mangaId) => CommentsNotifier(
    ref.read(commentRepositoryProvider),
    mangaId,
  ),
);

class CommentsState {
  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  final List<Comment> comments;
  final bool isLoading;
  final bool isSubmitting;
  final Object? error;

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isSubmitting,
    Object? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  CommentsNotifier(this._repo, this._mangaId)
      : super(const CommentsState(isLoading: true)) {
    _load();
  }

  final CommentRepository _repo;
  final String _mangaId;

  Future<void> _load() async {
    try {
      final comments = await _repo.getComments(_mangaId);
      state = state.copyWith(comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<bool> addComment(String content) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repo.addComment(_mangaId, content);
      await _load();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      return false;
    }
  }

  Future<bool> replyToComment(String parentId, String content) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repo.addComment(_mangaId, content, parentId: parentId);
      await _load();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      return false;
    }
  }

  Future<void> deleteComment(String commentId) async {
    await _repo.deleteComment(commentId);
    await _load();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _load();
  }
}

final userRatingProvider =
    StateNotifierProvider.family<UserRatingNotifier, AsyncValue<int?>, String>(
  (ref, mangaId) => UserRatingNotifier(
    ref.read(commentRepositoryProvider),
    mangaId,
  ),
);

class UserRatingNotifier extends StateNotifier<AsyncValue<int?>> {
  UserRatingNotifier(this._repo, this._mangaId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final CommentRepository _repo;
  final String _mangaId;

  Future<void> _load() async {
    try {
      final rating = await _repo.getUserRating(_mangaId);
      state = AsyncValue.data(rating);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitRating(int rating) async {
    await _repo.ratemanga(_mangaId, rating);
    state = AsyncValue.data(rating);
  }
}
