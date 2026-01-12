import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friendship.dart';
import '../models/user.dart';

class FriendService {
  // Firestore collection references
  final CollectionReference<Map<String, dynamic>> _friendshipsCollection =
      FirebaseFirestore.instance.collection('friendships');
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // ============================================================================
  // Friend Request Operations
  // ============================================================================

  /// Send a friend request
  Future<Friendship> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    // Check if friendship already exists
    final existing = await _findExistingFriendship(senderId, receiverId);
    if (existing != null) {
      throw FriendshipException('Friend request already exists');
    }

    final now = DateTime.now();
    final friendshipId = '${senderId}_$receiverId';
    final friendship = Friendship(
      id: friendshipId,
      senderId: senderId,
      receiverId: receiverId,
      status: FriendshipStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    await _friendshipsCollection.doc(friendshipId).set(friendship.toFirestore());
    return friendship;
  }

  /// Accept a friend request
  Future<Friendship> acceptFriendRequest(String friendshipId) async {
    final doc = await _friendshipsCollection.doc(friendshipId).get();
    if (!doc.exists) {
      throw FriendshipException('Friend request not found');
    }

    final friendship = Friendship.fromFirestore(doc);
    if (!friendship.isPending) {
      throw FriendshipException('Friend request is not pending');
    }

    final updated = friendship.copyWith(
      status: FriendshipStatus.accepted,
      updatedAt: DateTime.now(),
    );

    await _friendshipsCollection.doc(friendshipId).update(updated.toFirestore());
    return updated;
  }

  /// Reject a friend request
  Future<Friendship> rejectFriendRequest(String friendshipId) async {
    final doc = await _friendshipsCollection.doc(friendshipId).get();
    if (!doc.exists) {
      throw FriendshipException('Friend request not found');
    }

    final friendship = Friendship.fromFirestore(doc);
    if (!friendship.isPending) {
      throw FriendshipException('Friend request is not pending');
    }

    final updated = friendship.copyWith(
      status: FriendshipStatus.rejected,
      updatedAt: DateTime.now(),
    );

    await _friendshipsCollection.doc(friendshipId).update(updated.toFirestore());
    return updated;
  }

  /// Block a user
  Future<Friendship> blockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    final existing = await _findExistingFriendship(blockerId, blockedUserId);
    final now = DateTime.now();

    if (existing != null) {
      // Update existing friendship to blocked
      final updated = existing.copyWith(
        status: FriendshipStatus.blocked,
        updatedAt: now,
      );
      await _friendshipsCollection.doc(existing.id).update(updated.toFirestore());
      return updated;
    } else {
      // Create new blocked friendship
      final friendshipId = '${blockerId}_$blockedUserId';
      final friendship = Friendship(
        id: friendshipId,
        senderId: blockerId,
        receiverId: blockedUserId,
        status: FriendshipStatus.blocked,
        createdAt: now,
        updatedAt: now,
      );
      await _friendshipsCollection.doc(friendshipId).set(friendship.toFirestore());
      return friendship;
    }
  }

  /// Unblock a user (removes the friendship record)
  Future<void> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    final existing = await _findExistingFriendship(blockerId, blockedUserId);
    if (existing != null && existing.isBlocked) {
      await _friendshipsCollection.doc(existing.id).delete();
    }
  }

  /// Remove a friend (unfriend)
  Future<void> removeFriend(String friendshipId) async {
    await _friendshipsCollection.doc(friendshipId).delete();
  }

  // ============================================================================
  // Query Operations
  // ============================================================================

  /// Get all friends for a user (accepted friendships) - returns both sent and received
  Future<List<Friendship>> getFriends(String userId) async {
    // Query where user is sender
    final sentQuery = await _friendshipsCollection
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    // Query where user is receiver
    final receivedQuery = await _friendshipsCollection
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final friendships = <Friendship>[];
    for (final doc in sentQuery.docs) {
      friendships.add(Friendship.fromFirestore(doc));
    }
    for (final doc in receivedQuery.docs) {
      friendships.add(Friendship.fromFirestore(doc));
    }

    return friendships;
  }

  /// Get pending friend requests received by a user
  Future<List<Friendship>> getPendingRequests(String userId) async {
    final snapshot = await _friendshipsCollection
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) => Friendship.fromFirestore(doc)).toList();
  }

  /// Get pending friend requests sent by a user
  Future<List<Friendship>> getSentRequests(String userId) async {
    final snapshot = await _friendshipsCollection
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) => Friendship.fromFirestore(doc)).toList();
  }

  /// Get blocked users for a user
  Future<List<Friendship>> getBlockedUsers(String userId) async {
    final snapshot = await _friendshipsCollection
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'blocked')
        .get();

    return snapshot.docs.map((doc) => Friendship.fromFirestore(doc)).toList();
  }

  /// Check if two users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    final friendship = await _findExistingFriendship(userId1, userId2);
    return friendship != null && friendship.isAccepted;
  }

  /// Check if a user is blocked
  Future<bool> isBlocked(String blockerId, String blockedUserId) async {
    final friendship = await _findExistingFriendship(blockerId, blockedUserId);
    return friendship != null && friendship.isBlocked;
  }

  /// Get friendship status between two users
  Future<FriendshipStatus?> getFriendshipStatus(String userId1, String userId2) async {
    final friendship = await _findExistingFriendship(userId1, userId2);
    return friendship?.status;
  }

  /// Get a specific friendship by ID
  Future<Friendship?> getFriendship(String friendshipId) async {
    final doc = await _friendshipsCollection.doc(friendshipId).get();
    if (!doc.exists) return null;
    return Friendship.fromFirestore(doc);
  }

  // ============================================================================
  // User Search Operations
  // ============================================================================

  /// Search users from Firebase Firestore (for finding new friends)
  Future<List<User>> searchUsersFirestore(String query, {String? excludeUserId}) async {
    if (query.isEmpty || query.length < 2) return [];

    final queryLower = query.toLowerCase();

    // Query users where displayName starts with query (prefix search)
    final snapshot = await _usersCollection
        .orderBy('displayName')
        .startAt([queryLower])
        .endAt(['$queryLower\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => User.fromFirestore(doc))
        .where((user) => excludeUserId == null || user.id != excludeUserId)
        .toList();
  }

  /// Get user by ID from Firestore
  Future<User?> getUser(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    return User.fromFirestore(doc);
  }

  /// Get multiple users by IDs from Firestore
  Future<List<User>> getUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // Firestore limits 'in' queries to 30 items
    final users = <User>[];
    for (var i = 0; i < userIds.length; i += 30) {
      final batch = userIds.skip(i).take(30).toList();
      final snapshot = await _usersCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in snapshot.docs) {
        users.add(User.fromFirestore(doc));
      }
    }

    return users;
  }

  /// Get friend users (resolved from friendships)
  Future<List<User>> getFriendUsers(String userId) async {
    final friendships = await getFriends(userId);
    final friendIds = friendships
        .map((f) => f.getOtherUserId(userId))
        .toList();
    return getUsers(friendIds);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Find existing friendship between two users (in either direction)
  Future<Friendship?> _findExistingFriendship(String userId1, String userId2) async {
    // Check direction: user1->user2
    final key1 = '${userId1}_$userId2';
    final doc1 = await _friendshipsCollection.doc(key1).get();
    if (doc1.exists) {
      return Friendship.fromFirestore(doc1);
    }

    // Check direction: user2->user1
    final key2 = '${userId2}_$userId1';
    final doc2 = await _friendshipsCollection.doc(key2).get();
    if (doc2.exists) {
      return Friendship.fromFirestore(doc2);
    }

    return null;
  }

  /// Get friend count for a user
  Future<int> getFriendCount(String userId) async {
    final friends = await getFriends(userId);
    return friends.length;
  }

  /// Get pending request count for a user
  Future<int> getPendingRequestCount(String userId) async {
    final requests = await getPendingRequests(userId);
    return requests.length;
  }
}

/// Custom exception for friendship operations
class FriendshipException implements Exception {
  final String message;
  FriendshipException(this.message);

  @override
  String toString() => 'FriendshipException: $message';
}
