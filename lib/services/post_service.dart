import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/community_post.dart';
import '../models/user.dart';

class PostService {
  static const String _postsBox = 'community_posts';
  static const String _usersBox = 'users';
  static const _uuid = Uuid();

  // Get Hive boxes
  Box<CommunityPost> get _posts => Hive.box<CommunityPost>(_postsBox);
  Box<User> get _users => Hive.box<User>(_usersBox);

  // ============================================================================
  // Post CRUD Operations
  // ============================================================================

  /// Create a new post
  Future<CommunityPost> createPost({
    required String authorId,
    required String content,
    String? imageUrl,
    String? linkedRecipeId,
    List<String> tags = const [],
    bool isAnonymous = true,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    // Generate anonymous identity
    final anonymousName = AnonymousNameGenerator.generateName();
    final avatar = AnonymousNameGenerator.generateAvatar();

    // Get user badge if any
    final user = _users.get(authorId);
    final badge = _calculateUserBadge(user);

    final post = CommunityPost(
      id: id,
      authorId: authorId,
      anonymousName: anonymousName,
      avatar: avatar,
      content: content,
      imageUrl: imageUrl,
      badge: badge,
      likedByUserIds: [],
      commentsCount: 0,
      createdAt: now,
      updatedAt: now,
      isAnonymous: isAnonymous,
      linkedRecipeId: linkedRecipeId,
      tags: tags,
    );

    await _posts.put(id, post);
    return post;
  }

  /// Update a post
  Future<CommunityPost> updatePost({
    required String postId,
    String? content,
    String? imageUrl,
    List<String>? tags,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw PostException('Post not found');
    }

    final updated = post.copyWith(
      content: content,
      imageUrl: imageUrl,
      tags: tags,
      updatedAt: DateTime.now(),
    );

    await _posts.put(postId, updated);
    return updated;
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _posts.delete(postId);
  }

  /// Get a post by ID
  CommunityPost? getPost(String postId) {
    return _posts.get(postId);
  }

  // ============================================================================
  // Feed Operations
  // ============================================================================

  /// Get community feed (all posts, newest first)
  List<CommunityPost> getFeed({int limit = 50, int offset = 0}) {
    final allPosts = _posts.values.toList();
    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset >= allPosts.length) return [];

    final end = (offset + limit).clamp(0, allPosts.length);
    return allPosts.sublist(offset, end);
  }

  /// Get posts by a specific user
  List<CommunityPost> getUserPosts(String userId, {int limit = 50}) {
    final userPosts = _posts.values
        .where((p) => p.authorId == userId)
        .toList();
    userPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userPosts.take(limit).toList();
  }

  /// Get posts from friends only
  List<CommunityPost> getFriendsPosts(List<String> friendIds, {int limit = 50}) {
    final friendPosts = _posts.values
        .where((p) => friendIds.contains(p.authorId))
        .toList();
    friendPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return friendPosts.take(limit).toList();
  }

  /// Get posts with a specific tag
  List<CommunityPost> getPostsByTag(String tag, {int limit = 50}) {
    final taggedPosts = _posts.values
        .where((p) => p.tags.contains(tag))
        .toList();
    taggedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return taggedPosts.take(limit).toList();
  }

  /// Get trending posts (most likes in recent period)
  List<CommunityPost> getTrendingPosts({
    int limit = 20,
    Duration period = const Duration(days: 7),
  }) {
    final cutoff = DateTime.now().subtract(period);
    final recentPosts = _posts.values
        .where((p) => p.createdAt.isAfter(cutoff))
        .toList();

    recentPosts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    return recentPosts.take(limit).toList();
  }

  // ============================================================================
  // Like Operations
  // ============================================================================

  /// Like a post
  Future<CommunityPost> likePost({
    required String postId,
    required String userId,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw PostException('Post not found');
    }

    final updated = post.addLike(userId);
    await _posts.put(postId, updated);
    return updated;
  }

  /// Unlike a post
  Future<CommunityPost> unlikePost({
    required String postId,
    required String userId,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw PostException('Post not found');
    }

    final updated = post.removeLike(userId);
    await _posts.put(postId, updated);
    return updated;
  }

  /// Toggle like on a post
  Future<CommunityPost> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw PostException('Post not found');
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
  // Comment Operations (count only for now)
  // ============================================================================

  /// Increment comment count
  Future<CommunityPost> incrementCommentCount(String postId) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw PostException('Post not found');
    }

    final updated = post.copyWith(
      commentsCount: post.commentsCount + 1,
      updatedAt: DateTime.now(),
    );
    await _posts.put(postId, updated);
    return updated;
  }

  /// Decrement comment count
  Future<CommunityPost> decrementCommentCount(String postId) async {
    final post = _posts.get(postId);
    if (post == null) {
      throw PostException('Post not found');
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

  /// Get total post count
  int getTotalPostCount() {
    return _posts.length;
  }

  /// Get posts today count
  int getPostsTodayCount() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _posts.values
        .where((p) => p.createdAt.isAfter(startOfDay))
        .length;
  }

  /// Get user's total post count
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

  /// Calculate badge for user based on their activity/achievements
  String? _calculateUserBadge(User? user) {
    // This could be expanded to check user's challenge completions, streak, etc.
    // For now, return null - badges can be set manually or based on future criteria
    return null;
  }

  /// Seed sample posts for development/testing
  Future<void> seedSamplePosts() async {
    if (_posts.isNotEmpty) return; // Don't seed if posts exist

    final samplePosts = [
      CommunityPost(
        id: 'sample_1',
        authorId: 'system',
        anonymousName: 'Anonymous Butterfly',
        avatar: '🦋',
        badge: '14-Day Champion',
        content: 'Day 14 of no sugar! I never thought I could do it. The cravings have finally stopped and I feel so much more energized. Thank you all for the support! 💚',
        likedByUserIds: [],
        commentsCount: 45,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['milestone', 'sugar-free'],
      ),
      CommunityPost(
        id: 'sample_2',
        authorId: 'system',
        anonymousName: 'Gentle Sunrise',
        avatar: '🌅',
        badge: '7-Day Streak',
        content: 'Made my first sugar-free banana bread today! Used dates and mashed bananas for sweetness. My kids couldn\'t even tell the difference.',
        imageUrl: 'placeholder',
        likedByUserIds: [],
        commentsCount: 32,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        tags: ['recipe', 'sugar-free'],
      ),
      CommunityPost(
        id: 'sample_3',
        authorId: 'system',
        anonymousName: 'Quiet Mountain',
        avatar: '🏔️',
        content: 'Struggling today. Day 3 and the cravings are intense. Any tips for getting through the afternoon slump?',
        likedByUserIds: [],
        commentsCount: 78,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        tags: ['support'],
      ),
      CommunityPost(
        id: 'sample_4',
        authorId: 'system',
        anonymousName: 'Dancing Leaf',
        avatar: '🍃',
        badge: '30-Day Master',
        content: 'One month sugar-free! Here\'s what changed:\n\n• Better sleep\n• Clearer skin\n• More stable energy\n• No more brain fog\n\nIt\'s worth it, trust the process! 🌿',
        likedByUserIds: [],
        commentsCount: 67,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        tags: ['milestone', 'sugar-free'],
      ),
    ];

    for (final post in samplePosts) {
      await _posts.put(post.id, post);
    }
  }
}

/// Custom exception for post operations
class PostException implements Exception {
  final String message;
  PostException(this.message);

  @override
  String toString() => 'PostException: $message';
}
