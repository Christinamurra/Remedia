import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_post.dart';
import '../models/user.dart';
import 'friend_service.dart';

class MealPostService {
  static const String _postsBox = 'meal_posts';
  static const String _usersBox = 'users';
  static const _uuid = Uuid();

  final FriendService _friendService = FriendService();

  // Get Hive boxes
  Box<MealPost> get _posts => Hive.box<MealPost>(_postsBox);
  Box<User> get _users => Hive.box<User>(_usersBox);

  // ============================================================================
  // Post CRUD Operations
  // ============================================================================

  /// Create a new meal post
  Future<MealPost> createPost({
    required String authorId,
    required String imageUrl,
    String? caption,
    String? linkedRecipeId,
    MealPostVisibility visibility = MealPostVisibility.friendsOnly,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final post = MealPost(
      id: id,
      authorId: authorId,
      imageUrl: imageUrl,
      caption: caption,
      linkedRecipeId: linkedRecipeId,
      visibility: visibility,
      likedByUserIds: [],
      commentsCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _posts.put(id, post);
    return post;
  }

  /// Update a meal post
  Future<MealPost> updatePost({
    required String postId,
    String? caption,
    String? linkedRecipeId,
    MealPostVisibility? visibility,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw MealPostException('Post not found');
    }

    final updated = post.copyWith(
      caption: caption ?? post.caption,
      linkedRecipeId: linkedRecipeId ?? post.linkedRecipeId,
      visibility: visibility ?? post.visibility,
      updatedAt: DateTime.now(),
    );

    await _posts.put(postId, updated);
    return updated;
  }

  /// Delete a meal post
  Future<void> deletePost(String postId) async {
    await _posts.delete(postId);
  }

  /// Get a post by ID
  MealPost? getPost(String postId) {
    return _posts.get(postId);
  }

  // ============================================================================
  // Feed Operations
  // ============================================================================

  /// Get social feed (For You - friends' posts + public posts from others)
  /// Posts are filtered by visibility: friends' posts (any visibility) + public posts from non-friends
  List<MealPost> getSocialFeed(String currentUserId, {int limit = 50, int offset = 0}) {
    // Get friend IDs
    final friendIds = _getFriendIds(currentUserId);
    final friendIdSet = Set<String>.from(friendIds);

    // Get all posts, filter by visibility rules
    final visiblePosts = _posts.values.where((post) {
      // User's own posts
      if (post.authorId == currentUserId) return true;

      // Friends' posts (any visibility)
      if (friendIdSet.contains(post.authorId)) return true;

      // Public posts from non-friends
      if (post.isPublic) return true;

      return false;
    }).toList();

    // Sort by creation date (newest first)
    visiblePosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (offset >= visiblePosts.length) return [];
    final end = (offset + limit).clamp(0, visiblePosts.length);
    return visiblePosts.sublist(offset, end);
  }

  /// Get following feed (friends only)
  List<MealPost> getFriendsFeed(String currentUserId, {int limit = 50, int offset = 0}) {
    final friendIds = _getFriendIds(currentUserId);
    final friendIdSet = Set<String>.from(friendIds);

    // Include user's own posts + friends' posts
    final friendPosts = _posts.values.where((post) {
      return post.authorId == currentUserId || friendIdSet.contains(post.authorId);
    }).toList();

    friendPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset >= friendPosts.length) return [];
    final end = (offset + limit).clamp(0, friendPosts.length);
    return friendPosts.sublist(offset, end);
  }

  /// Get posts by a specific user (for profile view)
  /// Returns all posts if viewing own profile or if friend, only public posts otherwise
  List<MealPost> getUserPosts(String userId, {String? viewerId, int limit = 50}) {
    final userPosts = _posts.values.where((post) {
      if (post.authorId != userId) return false;

      // If no viewer specified or viewing own posts, show all
      if (viewerId == null || viewerId == userId) return true;

      // If viewer is a friend, show all posts
      if (_friendService.areFriends(viewerId, userId)) return true;

      // Otherwise only show public posts
      return post.isPublic;
    }).toList();

    userPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userPosts.take(limit).toList();
  }

  /// Get public posts (for discovery/explore)
  List<MealPost> getPublicPosts({int limit = 50, int offset = 0}) {
    final publicPosts = _posts.values.where((post) => post.isPublic).toList();
    publicPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset >= publicPosts.length) return [];
    final end = (offset + limit).clamp(0, publicPosts.length);
    return publicPosts.sublist(offset, end);
  }

  // ============================================================================
  // Like Operations
  // ============================================================================

  /// Like a post
  Future<MealPost> likePost({
    required String postId,
    required String userId,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw MealPostException('Post not found');
    }

    final updated = post.addLike(userId);
    await _posts.put(postId, updated);
    return updated;
  }

  /// Unlike a post
  Future<MealPost> unlikePost({
    required String postId,
    required String userId,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw MealPostException('Post not found');
    }

    final updated = post.removeLike(userId);
    await _posts.put(postId, updated);
    return updated;
  }

  /// Toggle like on a post
  Future<MealPost> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw MealPostException('Post not found');
    }

    final updated = post.toggleLike(userId);
    await _posts.put(postId, updated);
    return updated;
  }

  /// Check if user has liked a post
  bool hasLiked(String postId, String userId) {
    final post = _posts.get(postId);
    return post?.isLikedBy(userId) ?? false;
  }

  // ============================================================================
  // Comment Operations (count only - uses existing comment service)
  // ============================================================================

  /// Increment comment count
  Future<MealPost> incrementCommentCount(String postId) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw MealPostException('Post not found');
    }

    final updated = post.copyWith(
      commentsCount: post.commentsCount + 1,
      updatedAt: DateTime.now(),
    );
    await _posts.put(postId, updated);
    return updated;
  }

  /// Decrement comment count
  Future<MealPost> decrementCommentCount(String postId) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw MealPostException('Post not found');
    }

    final updated = post.copyWith(
      commentsCount: (post.commentsCount - 1).clamp(0, post.commentsCount),
      updatedAt: DateTime.now(),
    );
    await _posts.put(postId, updated);
    return updated;
  }

  // ============================================================================
  // Stats Operations
  // ============================================================================

  /// Get total meal post count
  int getTotalPostCount() {
    return _posts.length;
  }

  /// Get user's total meal post count
  int getUserPostCount(String userId) {
    return _posts.values.where((p) => p.authorId == userId).length;
  }

  /// Get user's total likes received
  int getUserTotalLikes(String userId) {
    return _posts.values
        .where((p) => p.authorId == userId)
        .fold(0, (sum, post) => sum + post.likesCount);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Get friend IDs for a user
  List<String> _getFriendIds(String userId) {
    final friendships = _friendService.getFriends(userId);
    return friendships.map((f) => f.getOtherUserId(userId)).toList();
  }

  /// Get user by ID
  User? getUser(String userId) {
    return _users.get(userId);
  }
}

/// Custom exception for meal post operations
class MealPostException implements Exception {
  final String message;
  MealPostException(this.message);

  @override
  String toString() => 'MealPostException: $message';
}
