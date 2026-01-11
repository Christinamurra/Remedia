import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/comment.dart';
import '../models/community_post.dart';

class CommentService {
  static const String _commentsBox = 'comments';
  static const String _postsBox = 'community_posts';
  static const _uuid = Uuid();

  // Get Hive boxes
  Box<Comment> get _comments => Hive.box<Comment>(_commentsBox);
  Box<CommunityPost> get _posts => Hive.box<CommunityPost>(_postsBox);

  // ============================================================================
  // Comment CRUD Operations
  // ============================================================================

  /// Create a new comment on a post
  Future<Comment> createComment({
    required String postId,
    required String authorId,
    required String content,
    String? parentCommentId,
    bool isAnonymous = true,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    // Generate anonymous identity
    final anonymousName = _generateAnonymousName();
    final avatar = _generateAvatar();

    final comment = Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      anonymousName: anonymousName,
      avatar: avatar,
      content: content,
      likedByUserIds: [],
      createdAt: now,
      updatedAt: now,
      parentCommentId: parentCommentId,
      isAnonymous: isAnonymous,
    );

    await _comments.put(id, comment);

    // Update post comment count
    await _updatePostCommentCount(postId, 1);

    return comment;
  }

  /// Update a comment
  Future<Comment> updateComment({
    required String commentId,
    required String content,
  }) async {
    final comment = _comments.get(commentId);
    if (comment == null) {
      throw CommentException('Comment not found');
    }

    final updated = comment.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );

    await _comments.put(commentId, updated);
    return updated;
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    final comment = _comments.get(commentId);
    if (comment == null) return;

    // Delete all replies to this comment
    final replies = getCommentReplies(commentId);
    for (final reply in replies) {
      await _comments.delete(reply.id);
    }

    // Delete the comment itself
    await _comments.delete(commentId);

    // Update post comment count (including replies)
    await _updatePostCommentCount(comment.postId, -(1 + replies.length));
  }

  /// Get a comment by ID
  Comment? getComment(String commentId) {
    return _comments.get(commentId);
  }

  // ============================================================================
  // Query Operations
  // ============================================================================

  /// Get all comments for a post (top-level only)
  List<Comment> getPostComments(String postId) {
    final comments = _comments.values
        .where((c) => c.postId == postId && c.parentCommentId == null)
        .toList();
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return comments;
  }

  /// Get all comments for a post including replies (flat list)
  List<Comment> getAllPostComments(String postId) {
    final comments = _comments.values
        .where((c) => c.postId == postId)
        .toList();
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  /// Get replies to a comment
  List<Comment> getCommentReplies(String commentId) {
    final replies = _comments.values
        .where((c) => c.parentCommentId == commentId)
        .toList();
    replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return replies;
  }

  /// Get comment count for a post
  int getCommentCount(String postId) {
    return _comments.values.where((c) => c.postId == postId).length;
  }

  // ============================================================================
  // Like Operations
  // ============================================================================

  /// Like a comment
  Future<Comment> likeComment({
    required String commentId,
    required String userId,
  }) async {
    final comment = _comments.get(commentId);
    if (comment == null) {
      throw CommentException('Comment not found');
    }

    final updated = comment.addLike(userId);
    await _comments.put(commentId, updated);
    return updated;
  }

  /// Unlike a comment
  Future<Comment> unlikeComment({
    required String commentId,
    required String userId,
  }) async {
    final comment = _comments.get(commentId);
    if (comment == null) {
      throw CommentException('Comment not found');
    }

    final updated = comment.removeLike(userId);
    await _comments.put(commentId, updated);
    return updated;
  }

  /// Toggle like on a comment
  Future<Comment> toggleLike({
    required String commentId,
    required String userId,
  }) async {
    final comment = _comments.get(commentId);
    if (comment == null) {
      throw CommentException('Comment not found');
    }

    final updated = comment.toggleLike(userId);
    await _comments.put(commentId, updated);
    return updated;
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Update post comment count
  Future<void> _updatePostCommentCount(String postId, int delta) async {
    final post = _posts.get(postId);
    if (post != null) {
      final updated = post.copyWith(
        commentsCount: (post.commentsCount + delta).clamp(0, 999999),
        updatedAt: DateTime.now(),
      );
      await _posts.put(postId, updated);
    }
  }

  /// Generate anonymous name for comment
  String _generateAnonymousName() {
    const adjectives = [
      'Gentle',
      'Quiet',
      'Dancing',
      'Shining',
      'Peaceful',
      'Wandering',
      'Dreaming',
      'Glowing',
      'Floating',
      'Rising',
      'Kind',
      'Brave',
      'Warm',
      'Bright',
      'Calm',
    ];

    const nouns = [
      'Butterfly',
      'Sunrise',
      'Mountain',
      'Leaf',
      'River',
      'Star',
      'Cloud',
      'Flower',
      'Moon',
      'Ocean',
      'Breeze',
      'Meadow',
      'Forest',
      'Rain',
      'Light',
    ];

    final adjective = adjectives[DateTime.now().microsecond % adjectives.length];
    final noun = nouns[DateTime.now().millisecond % nouns.length];
    return '$adjective $noun';
  }

  /// Generate avatar for comment
  String _generateAvatar() {
    const avatars = [
      '🦋',
      '🌅',
      '🏔️',
      '🍃',
      '🌊',
      '⭐',
      '☁️',
      '🌸',
      '🌙',
      '🌻',
      '🌈',
      '🦊',
      '🐦',
      '🌺',
      '🍀',
    ];
    return avatars[DateTime.now().millisecond % avatars.length];
  }
}

/// Custom exception for comment operations
class CommentException implements Exception {
  final String message;
  CommentException(this.message);

  @override
  String toString() => 'CommentException: $message';
}
