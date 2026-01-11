import 'package:hive/hive.dart';
import '../models/friendship.dart';
import '../models/user.dart';

class FriendService {
  static const String _friendshipsBox = 'friendships';
  static const String _usersBox = 'users';

  // Get Hive boxes
  Box<Friendship> get _friendships => Hive.box<Friendship>(_friendshipsBox);
  Box<User> get _users => Hive.box<User>(_usersBox);

  // ============================================================================
  // Friend Request Operations
  // ============================================================================

  /// Send a friend request
  Future<Friendship> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    // Check if friendship already exists
    final existing = _findExistingFriendship(senderId, receiverId);
    if (existing != null) {
      throw FriendshipException('Friend request already exists');
    }

    final now = DateTime.now();
    final friendship = Friendship(
      id: '${senderId}_$receiverId',
      senderId: senderId,
      receiverId: receiverId,
      status: FriendshipStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    await _friendships.put(friendship.id, friendship);
    return friendship;
  }

  /// Accept a friend request
  Future<Friendship> acceptFriendRequest(String friendshipId) async {
    final friendship = _friendships.get(friendshipId);
    if (friendship == null) {
      throw FriendshipException('Friend request not found');
    }

    if (!friendship.isPending) {
      throw FriendshipException('Friend request is not pending');
    }

    final updated = friendship.copyWith(
      status: FriendshipStatus.accepted,
      updatedAt: DateTime.now(),
    );

    await _friendships.put(friendshipId, updated);
    return updated;
  }

  /// Reject a friend request
  Future<Friendship> rejectFriendRequest(String friendshipId) async {
    final friendship = _friendships.get(friendshipId);
    if (friendship == null) {
      throw FriendshipException('Friend request not found');
    }

    if (!friendship.isPending) {
      throw FriendshipException('Friend request is not pending');
    }

    final updated = friendship.copyWith(
      status: FriendshipStatus.rejected,
      updatedAt: DateTime.now(),
    );

    await _friendships.put(friendshipId, updated);
    return updated;
  }

  /// Block a user
  Future<Friendship> blockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    final existing = _findExistingFriendship(blockerId, blockedUserId);
    final now = DateTime.now();

    if (existing != null) {
      // Update existing friendship to blocked
      final updated = existing.copyWith(
        status: FriendshipStatus.blocked,
        updatedAt: now,
      );
      await _friendships.put(existing.id, updated);
      return updated;
    } else {
      // Create new blocked friendship
      final friendship = Friendship(
        id: '${blockerId}_$blockedUserId',
        senderId: blockerId,
        receiverId: blockedUserId,
        status: FriendshipStatus.blocked,
        createdAt: now,
        updatedAt: now,
      );
      await _friendships.put(friendship.id, friendship);
      return friendship;
    }
  }

  /// Unblock a user (removes the friendship record)
  Future<void> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    final existing = _findExistingFriendship(blockerId, blockedUserId);
    if (existing != null && existing.isBlocked) {
      await _friendships.delete(existing.id);
    }
  }

  /// Remove a friend (unfriend)
  Future<void> removeFriend(String friendshipId) async {
    await _friendships.delete(friendshipId);
  }

  // ============================================================================
  // Query Operations
  // ============================================================================

  /// Get all friends for a user (accepted friendships)
  List<Friendship> getFriends(String userId) {
    return _friendships.values
        .where((f) =>
            f.isAccepted &&
            (f.senderId == userId || f.receiverId == userId))
        .toList();
  }

  /// Get pending friend requests received by a user
  List<Friendship> getPendingRequests(String userId) {
    return _friendships.values
        .where((f) => f.isPending && f.receiverId == userId)
        .toList();
  }

  /// Get pending friend requests sent by a user
  List<Friendship> getSentRequests(String userId) {
    return _friendships.values
        .where((f) => f.isPending && f.senderId == userId)
        .toList();
  }

  /// Get blocked users for a user
  List<Friendship> getBlockedUsers(String userId) {
    return _friendships.values
        .where((f) => f.isBlocked && f.senderId == userId)
        .toList();
  }

  /// Check if two users are friends
  bool areFriends(String userId1, String userId2) {
    final friendship = _findExistingFriendship(userId1, userId2);
    return friendship != null && friendship.isAccepted;
  }

  /// Check if a user is blocked
  bool isBlocked(String blockerId, String blockedUserId) {
    final friendship = _findExistingFriendship(blockerId, blockedUserId);
    return friendship != null && friendship.isBlocked;
  }

  /// Get friendship status between two users
  FriendshipStatus? getFriendshipStatus(String userId1, String userId2) {
    final friendship = _findExistingFriendship(userId1, userId2);
    return friendship?.status;
  }

  /// Get a specific friendship by ID
  Friendship? getFriendship(String friendshipId) {
    return _friendships.get(friendshipId);
  }

  // ============================================================================
  // User Search Operations
  // ============================================================================

  /// Search users by display name (for adding friends)
  List<User> searchUsers(String query, {String? excludeUserId}) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _users.values.where((user) {
      if (excludeUserId != null && user.id == excludeUserId) return false;
      return user.displayName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get user by ID
  User? getUser(String userId) {
    return _users.get(userId);
  }

  /// Get multiple users by IDs
  List<User> getUsers(List<String> userIds) {
    return userIds
        .map((id) => _users.get(id))
        .where((user) => user != null)
        .cast<User>()
        .toList();
  }

  /// Get friend users (resolved from friendships)
  List<User> getFriendUsers(String userId) {
    final friendships = getFriends(userId);
    final friendIds = friendships
        .map((f) => f.getOtherUserId(userId))
        .toList();
    return getUsers(friendIds);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Find existing friendship between two users (in either direction)
  Friendship? _findExistingFriendship(String userId1, String userId2) {
    // Check both directions: user1->user2 and user2->user1
    final key1 = '${userId1}_$userId2';
    final key2 = '${userId2}_$userId1';

    return _friendships.get(key1) ?? _friendships.get(key2);
  }

  /// Get friend count for a user
  int getFriendCount(String userId) {
    return getFriends(userId).length;
  }

  /// Get pending request count for a user
  int getPendingRequestCount(String userId) {
    return getPendingRequests(userId).length;
  }
}

/// Custom exception for friendship operations
class FriendshipException implements Exception {
  final String message;
  FriendshipException(this.message);

  @override
  String toString() => 'FriendshipException: $message';
}
