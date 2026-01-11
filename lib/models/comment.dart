import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'comment.g.dart';

@HiveType(typeId: 10)
class Comment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String postId; // The post this comment belongs to

  @HiveField(2)
  final String authorId;

  @HiveField(3)
  final String anonymousName;

  @HiveField(4)
  final String avatar;

  @HiveField(5)
  final String content;

  @HiveField(6)
  final List<String> likedByUserIds;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final String? parentCommentId; // For replies (null = top-level comment)

  @HiveField(10)
  final bool isAnonymous;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.anonymousName,
    required this.avatar,
    required this.content,
    this.likedByUserIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.parentCommentId,
    this.isAnonymous = true,
  });

  // Computed properties
  int get likesCount => likedByUserIds.length;
  bool get isReply => parentCommentId != null;

  bool isLikedBy(String userId) => likedByUserIds.contains(userId);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // CopyWith method
  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? anonymousName,
    String? avatar,
    String? content,
    List<String>? likedByUserIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentCommentId,
    bool? isAnonymous,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      anonymousName: anonymousName ?? this.anonymousName,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  // Add a like
  Comment addLike(String userId) {
    if (likedByUserIds.contains(userId)) return this;
    return copyWith(
      likedByUserIds: [...likedByUserIds, userId],
      updatedAt: DateTime.now(),
    );
  }

  // Remove a like
  Comment removeLike(String userId) {
    if (!likedByUserIds.contains(userId)) return this;
    return copyWith(
      likedByUserIds: likedByUserIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Toggle like
  Comment toggleLike(String userId) {
    return isLikedBy(userId) ? removeLike(userId) : addLike(userId);
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'anonymousName': anonymousName,
      'avatar': avatar,
      'content': content,
      'likedByUserIds': likedByUserIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'parentCommentId': parentCommentId,
      'isAnonymous': isAnonymous,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      postId: map['postId'] as String,
      authorId: map['authorId'] as String,
      anonymousName: map['anonymousName'] as String,
      avatar: map['avatar'] as String,
      content: map['content'] as String,
      likedByUserIds: List<String>.from(map['likedByUserIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      parentCommentId: map['parentCommentId'] as String?,
      isAnonymous: map['isAnonymous'] as bool? ?? true,
    );
  }

  // Serialization for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'anonymousName': anonymousName,
      'avatar': avatar,
      'content': content,
      'likedByUserIds': likedByUserIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'parentCommentId': parentCommentId,
      'isAnonymous': isAnonymous,
    };
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment.fromFirestoreMap(data, doc.id);
  }

  factory Comment.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      postId: data['postId'] as String,
      authorId: data['authorId'] as String,
      anonymousName: data['anonymousName'] as String,
      avatar: data['avatar'] as String,
      content: data['content'] as String,
      likedByUserIds: List<String>.from(data['likedByUserIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      parentCommentId: data['parentCommentId'] as String?,
      isAnonymous: data['isAnonymous'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, postId: $postId, author: $anonymousName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
