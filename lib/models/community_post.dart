import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'community_post.g.dart';

@HiveType(typeId: 9)
class CommunityPost {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String authorId; // User ID of the author

  @HiveField(2)
  final String anonymousName; // Display name (e.g., "Anonymous Butterfly")

  @HiveField(3)
  final String avatar; // Emoji avatar

  @HiveField(4)
  final String content;

  @HiveField(5)
  final String? imageUrl; // Optional image

  @HiveField(6)
  final String? badge; // Optional badge (e.g., "14-Day Champion")

  @HiveField(7)
  final List<String> likedByUserIds; // Users who liked this post

  @HiveField(8)
  final int commentsCount;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final bool isAnonymous;

  @HiveField(12)
  final String? linkedRecipeId; // Optional linked recipe

  @HiveField(13)
  final List<String> tags; // Tags like "sugar-free", "recipe", "milestone"

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.anonymousName,
    required this.avatar,
    required this.content,
    this.imageUrl,
    this.badge,
    this.likedByUserIds = const [],
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isAnonymous = true,
    this.linkedRecipeId,
    this.tags = const [],
  });

  // Computed properties
  int get likesCount => likedByUserIds.length;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool isLikedBy(String userId) => likedByUserIds.contains(userId);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // CopyWith method
  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? anonymousName,
    String? avatar,
    String? content,
    String? imageUrl,
    String? badge,
    List<String>? likedByUserIds,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
    String? linkedRecipeId,
    List<String>? tags,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      anonymousName: anonymousName ?? this.anonymousName,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      badge: badge ?? this.badge,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
      tags: tags ?? this.tags,
    );
  }

  // Add a like
  CommunityPost addLike(String userId) {
    if (likedByUserIds.contains(userId)) return this;
    return copyWith(
      likedByUserIds: [...likedByUserIds, userId],
      updatedAt: DateTime.now(),
    );
  }

  // Remove a like
  CommunityPost removeLike(String userId) {
    if (!likedByUserIds.contains(userId)) return this;
    return copyWith(
      likedByUserIds: likedByUserIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Toggle like
  CommunityPost toggleLike(String userId) {
    return isLikedBy(userId) ? removeLike(userId) : addLike(userId);
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'anonymousName': anonymousName,
      'avatar': avatar,
      'content': content,
      'imageUrl': imageUrl,
      'badge': badge,
      'likedByUserIds': likedByUserIds,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'linkedRecipeId': linkedRecipeId,
      'tags': tags,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] as String,
      authorId: map['authorId'] as String,
      anonymousName: map['anonymousName'] as String,
      avatar: map['avatar'] as String,
      content: map['content'] as String,
      imageUrl: map['imageUrl'] as String?,
      badge: map['badge'] as String?,
      likedByUserIds: List<String>.from(map['likedByUserIds'] ?? []),
      commentsCount: map['commentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isAnonymous: map['isAnonymous'] as bool? ?? true,
      linkedRecipeId: map['linkedRecipeId'] as String?,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Serialization for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'anonymousName': anonymousName,
      'avatar': avatar,
      'content': content,
      'imageUrl': imageUrl,
      'badge': badge,
      'likedByUserIds': likedByUserIds,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isAnonymous': isAnonymous,
      'linkedRecipeId': linkedRecipeId,
      'tags': tags,
    };
  }

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost.fromFirestoreMap(data, doc.id);
  }

  factory CommunityPost.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return CommunityPost(
      id: id,
      authorId: data['authorId'] as String,
      anonymousName: data['anonymousName'] as String,
      avatar: data['avatar'] as String,
      content: data['content'] as String,
      imageUrl: data['imageUrl'] as String?,
      badge: data['badge'] as String?,
      likedByUserIds: List<String>.from(data['likedByUserIds'] ?? []),
      commentsCount: data['commentsCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isAnonymous: data['isAnonymous'] as bool? ?? true,
      linkedRecipeId: data['linkedRecipeId'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  @override
  String toString() {
    return 'CommunityPost(id: $id, author: $anonymousName, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Anonymous name generator for posts
class AnonymousNameGenerator {
  static const List<String> adjectives = [
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
  ];

  static const List<String> nouns = [
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
  ];

  static const List<String> avatars = [
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
  ];

  static String generateName() {
    final adjective = adjectives[DateTime.now().microsecond % adjectives.length];
    final noun = nouns[DateTime.now().millisecond % nouns.length];
    return '$adjective $noun';
  }

  static String generateAvatar() {
    return avatars[DateTime.now().millisecond % avatars.length];
  }
}
