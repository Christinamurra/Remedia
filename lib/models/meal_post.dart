import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'meal_post.g.dart';

@HiveType(typeId: 12)
enum MealPostVisibility {
  @HiveField(0)
  friendsOnly,

  @HiveField(1)
  public,
}

@HiveType(typeId: 11)
class MealPost {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String authorId;

  @HiveField(2)
  final String imageUrl; // Firebase Storage URL (required)

  @HiveField(3)
  final String? caption;

  @HiveField(4)
  final String? linkedRecipeId; // Optional linked recipe

  @HiveField(5)
  final MealPostVisibility visibility;

  @HiveField(6)
  final List<String> likedByUserIds;

  @HiveField(7)
  final int commentsCount;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  MealPost({
    required this.id,
    required this.authorId,
    required this.imageUrl,
    this.caption,
    this.linkedRecipeId,
    this.visibility = MealPostVisibility.friendsOnly,
    this.likedByUserIds = const [],
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  int get likesCount => likedByUserIds.length;
  bool get hasCaption => caption != null && caption!.isNotEmpty;
  bool get hasLinkedRecipe => linkedRecipeId != null && linkedRecipeId!.isNotEmpty;
  bool get isPublic => visibility == MealPostVisibility.public;
  bool get isFriendsOnly => visibility == MealPostVisibility.friendsOnly;

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
  MealPost copyWith({
    String? id,
    String? authorId,
    String? imageUrl,
    String? caption,
    String? linkedRecipeId,
    MealPostVisibility? visibility,
    List<String>? likedByUserIds,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
      visibility: visibility ?? this.visibility,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Add a like
  MealPost addLike(String userId) {
    if (likedByUserIds.contains(userId)) return this;
    return copyWith(
      likedByUserIds: [...likedByUserIds, userId],
      updatedAt: DateTime.now(),
    );
  }

  // Remove a like
  MealPost removeLike(String userId) {
    if (!likedByUserIds.contains(userId)) return this;
    return copyWith(
      likedByUserIds: likedByUserIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Toggle like
  MealPost toggleLike(String userId) {
    return isLikedBy(userId) ? removeLike(userId) : addLike(userId);
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'imageUrl': imageUrl,
      'caption': caption,
      'linkedRecipeId': linkedRecipeId,
      'visibility': visibility.index,
      'likedByUserIds': likedByUserIds,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MealPost.fromMap(Map<String, dynamic> map) {
    return MealPost(
      id: map['id'] as String,
      authorId: map['authorId'] as String,
      imageUrl: map['imageUrl'] as String,
      caption: map['caption'] as String?,
      linkedRecipeId: map['linkedRecipeId'] as String?,
      visibility: MealPostVisibility.values[map['visibility'] as int? ?? 0],
      likedByUserIds: List<String>.from(map['likedByUserIds'] ?? []),
      commentsCount: map['commentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Serialization for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'imageUrl': imageUrl,
      'caption': caption,
      'linkedRecipeId': linkedRecipeId,
      'visibility': visibility.name,
      'likedByUserIds': likedByUserIds,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MealPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPost.fromFirestoreMap(data, doc.id);
  }

  factory MealPost.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return MealPost(
      id: id,
      authorId: data['authorId'] as String,
      imageUrl: data['imageUrl'] as String,
      caption: data['caption'] as String?,
      linkedRecipeId: data['linkedRecipeId'] as String?,
      visibility: MealPostVisibility.values.firstWhere(
        (v) => v.name == data['visibility'],
        orElse: () => MealPostVisibility.friendsOnly,
      ),
      likedByUserIds: List<String>.from(data['likedByUserIds'] ?? []),
      commentsCount: data['commentsCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return 'MealPost(id: $id, authorId: $authorId, visibility: ${visibility.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
