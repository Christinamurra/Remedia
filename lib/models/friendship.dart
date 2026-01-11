import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'friendship.g.dart';

enum FriendshipStatus {
  pending,
  accepted,
  rejected,
  blocked,
}

@HiveType(typeId: 5)
class Friendship {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderId; // User who sent request

  @HiveField(2)
  final String receiverId; // User who received request

  @HiveField(3)
  final FriendshipStatus status;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  Friendship({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isRejected => status == FriendshipStatus.rejected;
  bool get isBlocked => status == FriendshipStatus.blocked;

  // Check if current user is the sender
  bool isSentBy(String userId) => senderId == userId;

  // Check if current user is the receiver
  bool isReceivedBy(String userId) => receiverId == userId;

  // Get the other user's ID
  String getOtherUserId(String currentUserId) {
    return senderId == currentUserId ? receiverId : senderId;
  }

  // CopyWith method
  Friendship copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    FriendshipStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Friendship(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Friendship.fromMap(Map<String, dynamic> map) {
    return Friendship(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      status: FriendshipStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => FriendshipStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Serialization for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Friendship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Friendship(
      id: doc.id,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      status: _parseStatus(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory Friendship.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return Friendship(
      id: id,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      status: _parseStatus(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static FriendshipStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FriendshipStatus.pending;
      case 'accepted':
        return FriendshipStatus.accepted;
      case 'rejected':
        return FriendshipStatus.rejected;
      case 'blocked':
        return FriendshipStatus.blocked;
      default:
        return FriendshipStatus.pending;
    }
  }

  @override
  String toString() {
    return 'Friendship(id: $id, senderId: $senderId, receiverId: $receiverId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Friendship && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
