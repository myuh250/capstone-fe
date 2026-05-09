import '../models/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getComments(String mangaId, {int page = 1});
  Future<Comment> addComment(String mangaId, String content, {String? parentId});
  Future<void> editComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<int?> getUserRating(String mangaId);
  Future<void> ratemanga(String mangaId, int rating);
}

class FakeCommentRepository implements CommentRepository {
  final Map<String, List<Comment>> _comments = {};
  final Map<String, int> _ratings = {};
  int _idCounter = 100;

  @override
  Future<List<Comment>> getComments(String mangaId, {int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_comments.containsKey(mangaId)) {
      _comments[mangaId] = _generateFakeComments(mangaId);
    }
    return List.from(_comments[mangaId]!);
  }

  List<Comment> _generateFakeComments(String mangaId) {
    final now = DateTime.now();
    return [
      Comment(
        id: '${mangaId}_c1',
        mangaId: mangaId,
        userId: 'u1',
        userName: 'TrungKiên',
        content:
            'Bộ này đỉnh quá! Arc mới siêu hay, tác giả vẽ đẹp và nội dung rất ý nghĩa. Highly recommend cho mọi người!',
        createdAt: now.subtract(const Duration(hours: 3)),
        replies: [
          Comment(
            id: '${mangaId}_c1_r1',
            mangaId: mangaId,
            userId: 'u2',
            userName: 'MinhAnh',
            content: 'Đồng ý với bạn! Mình cũng vừa đọc xong và cảm thấy rất tuyệt vời.',
            createdAt: now.subtract(const Duration(hours: 2)),
            parentId: '${mangaId}_c1',
          ),
          Comment(
            id: '${mangaId}_c1_r2',
            mangaId: mangaId,
            userId: 'u3',
            userName: 'HồngNhung',
            content: 'Bạn đọc arc nào rồi? Mình mới đọc đến arc 3 thôi.',
            createdAt: now.subtract(const Duration(hours: 1)),
            parentId: '${mangaId}_c1',
          ),
        ],
      ),
      Comment(
        id: '${mangaId}_c2',
        mangaId: mangaId,
        userId: 'u4',
        userName: 'PhúcLong',
        content: 'Cốt truyện rất hay nhưng hơi kéo dài. Tuy nhiên character development rất tốt!',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Comment(
        id: '${mangaId}_c3',
        mangaId: mangaId,
        userId: 'u5',
        userName: 'ThảoVân',
        content: 'Vừa bắt đầu đọc, không biết có hay như mọi người nói không. Xem tiếp đã!',
        createdAt: now.subtract(const Duration(days: 2)),
        replies: [
          Comment(
            id: '${mangaId}_c3_r1',
            mangaId: mangaId,
            userId: 'u1',
            userName: 'TrungKiên',
            content: 'Kiên nhẫn đọc đến chapter 50 trở đi là sẽ thấy hay ngay á bạn!',
            createdAt: now.subtract(const Duration(days: 1, hours: 20)),
            parentId: '${mangaId}_c3',
          ),
        ],
      ),
      Comment(
        id: '${mangaId}_c4',
        mangaId: mangaId,
        userId: 'u6',
        userName: 'QuangHuy',
        content: '10/10, không có gì để chê. Một trong những bộ manga hay nhất mình từng đọc.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Comment(
        id: '${mangaId}_c5',
        mangaId: mangaId,
        userId: 'u7',
        userName: 'LanPhuong',
        content: 'Artwork rất đẹp, đặc biệt là những cảnh hành động siêu mãn nhãn!',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  @override
  Future<Comment> addComment(
    String mangaId,
    String content, {
    String? parentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final comment = Comment(
      id: 'new_${_idCounter++}',
      mangaId: mangaId,
      userId: 'current_user',
      userName: 'Bạn',
      content: content,
      createdAt: DateTime.now(),
      parentId: parentId,
    );
    if (!_comments.containsKey(mangaId)) {
      _comments[mangaId] = _generateFakeComments(mangaId);
    }
    if (parentId != null) {
      final parentIdx =
          _comments[mangaId]!.indexWhere((c) => c.id == parentId);
      if (parentIdx >= 0) {
        final parent = _comments[mangaId]![parentIdx];
        _comments[mangaId]![parentIdx] = parent.copyWith(
          replies: [...parent.replies, comment],
        );
      }
    } else {
      _comments[mangaId]!.insert(0, comment);
    }
    return comment;
  }

  @override
  Future<void> editComment(String commentId, String content) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final mangaId in _comments.keys) {
      _comments[mangaId]!.removeWhere((c) => c.id == commentId);
    }
  }

  @override
  Future<int?> getUserRating(String mangaId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _ratings[mangaId];
  }

  @override
  Future<void> ratemanga(String mangaId, int rating) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ratings[mangaId] = rating;
  }
}
