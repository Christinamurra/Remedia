import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'challenge_buddy.g.dart';

enum BuddyStatus {
  pending,    // Waiting for buddy to accept
  active,     // Both users are doing the challenge together
  completed,  // Challenge completed
  declined,   // Buddy declined the invite
}

enum BuddyMatchType {
  friend,     // Invited a friend
  random,     // Matched with a random person
}

@HiveType(typeId: 12)
class ChallengeBuddy {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String challengeId; // ID of the challenge type (e.g., '1' for 7-Day Sugar Free)

  @HiveField(2)
  final String challengeTitle; // Store title for display

  @HiveField(3)
  final String userId1; // First user (initiator)

  @HiveField(4)
  final String userId2; // Second user (buddy)

  @HiveField(5)
  final BuddyStatus status;

  @HiveField(6)
  final BuddyMatchType matchType;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final DateTime? startDate; // When both users started

  @HiveField(10)
  final int user1Progress; // Days completed by user1

  @HiveField(11)
  final int user2Progress; // Days completed by user2

  ChallengeBuddy({
    required this.id,
    required this.challengeId,
    required this.challengeTitle,
    required this.userId1,
    required this.userId2,
    required this.status,
    required this.matchType,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.user1Progress = 0,
    this.user2Progress = 0,
  });

  // Helper methods
  bool get isPending => status == BuddyStatus.pending;
  bool get isActive => status == BuddyStatus.active;
  bool get isCompleted => status == BuddyStatus.completed;
  bool get isDeclined => status == BuddyStatus.declined;

  bool isUser(String userId) => userId1 == userId || userId2 == userId;

  String getBuddyId(String currentUserId) {
    return userId1 == currentUserId ? userId2 : userId1;
  }

  int getMyProgress(String currentUserId) {
    return userId1 == currentUserId ? user1Progress : user2Progress;
  }

  int getBuddyProgress(String currentUserId) {
    return userId1 == currentUserId ? user2Progress : user1Progress;
  }

  bool isInitiator(String userId) => userId1 == userId;

  ChallengeBuddy copyWith({
    String? id,
    String? challengeId,
    String? challengeTitle,
    String? userId1,
    String? userId2,
    BuddyStatus? status,
    BuddyMatchType? matchType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    int? user1Progress,
    int? user2Progress,
  }) {
    return ChallengeBuddy(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      challengeTitle: challengeTitle ?? this.challengeTitle,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      status: status ?? this.status,
      matchType: matchType ?? this.matchType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      user1Progress: user1Progress ?? this.user1Progress,
      user2Progress: user2Progress ?? this.user2Progress,
    );
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challengeId': challengeId,
      'challengeTitle': challengeTitle,
      'userId1': userId1,
      'userId2': userId2,
      'status': status.toString(),
      'matchType': matchType.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'user1Progress': user1Progress,
      'user2Progress': user2Progress,
    };
  }

  factory ChallengeBuddy.fromMap(Map<String, dynamic> map) {
    return ChallengeBuddy(
      id: map['id'] as String,
      challengeId: map['challengeId'] as String,
      challengeTitle: map['challengeTitle'] as String,
      userId1: map['userId1'] as String,
      userId2: map['userId2'] as String,
      status: BuddyStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => BuddyStatus.pending,
      ),
      matchType: BuddyMatchType.values.firstWhere(
        (e) => e.toString() == map['matchType'],
        orElse: () => BuddyMatchType.friend,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      user1Progress: map['user1Progress'] as int? ?? 0,
      user2Progress: map['user2Progress'] as int? ?? 0,
    );
  }

  // Serialization for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'challengeId': challengeId,
      'challengeTitle': challengeTitle,
      'userId1': userId1,
      'userId2': userId2,
      'status': status.toString().split('.').last,
      'matchType': matchType.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'user1Progress': user1Progress,
      'user2Progress': user2Progress,
    };
  }

  factory ChallengeBuddy.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeBuddy.fromFirestoreMap(data, doc.id);
  }

  factory ChallengeBuddy.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return ChallengeBuddy(
      id: id,
      challengeId: data['challengeId'] as String,
      challengeTitle: data['challengeTitle'] as String,
      userId1: data['userId1'] as String,
      userId2: data['userId2'] as String,
      status: _parseStatus(data['status'] as String),
      matchType: _parseMatchType(data['matchType'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      user1Progress: data['user1Progress'] as int? ?? 0,
      user2Progress: data['user2Progress'] as int? ?? 0,
    );
  }

  static BuddyStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BuddyStatus.pending;
      case 'active':
        return BuddyStatus.active;
      case 'completed':
        return BuddyStatus.completed;
      case 'declined':
        return BuddyStatus.declined;
      default:
        return BuddyStatus.pending;
    }
  }

  static BuddyMatchType _parseMatchType(String matchType) {
    switch (matchType.toLowerCase()) {
      case 'friend':
        return BuddyMatchType.friend;
      case 'random':
        return BuddyMatchType.random;
      default:
        return BuddyMatchType.friend;
    }
  }

  @override
  String toString() {
    return 'ChallengeBuddy(id: $id, challengeId: $challengeId, userId1: $userId1, userId2: $userId2, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeBuddy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
