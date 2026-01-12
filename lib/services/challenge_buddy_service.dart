import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/challenge_buddy.dart';
import '../models/challenge.dart';
import '../models/user.dart';

class ChallengeBuddyService {
  static const String _buddiesBox = 'challenge_buddies';
  static const String _usersBox = 'users';
  static const String _waitingQueueCollection = 'buddy_waiting_queue';
  static const String _buddiesCollection = 'challenge_buddies';

  final _uuid = const Uuid();

  // Get Hive boxes
  Box<ChallengeBuddy> get _buddies => Hive.box<ChallengeBuddy>(_buddiesBox);
  Box<User> get _users => Hive.box<User>(_usersBox);

  // Firestore reference
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ============================================================================
  // Invite a Friend as Buddy
  // ============================================================================

  /// Invite a friend to do a challenge together
  Future<ChallengeBuddy> inviteFriend({
    required String userId,
    required String friendId,
    required Challenge challenge,
  }) async {
    // Check if buddy relationship already exists for this challenge
    final existing = _findExistingBuddy(userId, friendId, challenge.id);
    if (existing != null && (existing.isPending || existing.isActive)) {
      throw BuddyException('Buddy relationship already exists for this challenge');
    }

    final now = DateTime.now();
    final buddy = ChallengeBuddy(
      id: _uuid.v4(),
      challengeId: challenge.id,
      challengeTitle: challenge.title,
      userId1: userId,
      userId2: friendId,
      status: BuddyStatus.pending,
      matchType: BuddyMatchType.friend,
      createdAt: now,
      updatedAt: now,
    );

    // Save locally
    await _buddies.put(buddy.id, buddy);

    // Save to Firestore for the other user to see
    await _firestore.collection(_buddiesCollection).doc(buddy.id).set(buddy.toFirestore());

    return buddy;
  }

  // ============================================================================
  // Random Buddy Matching
  // ============================================================================

  /// Find a random buddy for a challenge
  /// This uses a waiting queue - if someone is waiting, match them; otherwise, join the queue
  Future<ChallengeBuddy?> findRandomBuddy({
    required String userId,
    required Challenge challenge,
  }) async {
    final now = DateTime.now();

    // Check if user is already in queue for this challenge
    final existingQueue = await _firestore
        .collection(_waitingQueueCollection)
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challenge.id)
        .get();

    if (existingQueue.docs.isNotEmpty) {
      // User is already waiting
      return null;
    }

    // Try to find someone waiting for this challenge
    final waitingUsers = await _firestore
        .collection(_waitingQueueCollection)
        .where('challengeId', isEqualTo: challenge.id)
        .where('userId', isNotEqualTo: userId)
        .orderBy('userId')
        .orderBy('createdAt')
        .limit(1)
        .get();

    if (waitingUsers.docs.isNotEmpty) {
      // Match found! Remove them from queue and create buddy relationship
      final matchDoc = waitingUsers.docs.first;
      final matchUserId = matchDoc['userId'] as String;

      // Delete from waiting queue
      await matchDoc.reference.delete();

      // Create buddy relationship (already active since both want to do it)
      final buddy = ChallengeBuddy(
        id: _uuid.v4(),
        challengeId: challenge.id,
        challengeTitle: challenge.title,
        userId1: matchUserId, // The person who was waiting is user1
        userId2: userId,      // Current user is user2
        status: BuddyStatus.active,
        matchType: BuddyMatchType.random,
        createdAt: now,
        updatedAt: now,
        startDate: now,
      );

      // Save locally
      await _buddies.put(buddy.id, buddy);

      // Save to Firestore
      await _firestore.collection(_buddiesCollection).doc(buddy.id).set(buddy.toFirestore());

      return buddy;
    } else {
      // No one waiting, add to queue
      await _firestore.collection(_waitingQueueCollection).add({
        'userId': userId,
        'challengeId': challenge.id,
        'challengeTitle': challenge.title,
        'createdAt': Timestamp.fromDate(now),
      });

      // Return null - user is now waiting
      return null;
    }
  }

  /// Cancel waiting for a random buddy
  Future<void> cancelRandomBuddySearch({
    required String userId,
    required String challengeId,
  }) async {
    final waitingDocs = await _firestore
        .collection(_waitingQueueCollection)
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .get();

    for (final doc in waitingDocs.docs) {
      await doc.reference.delete();
    }
  }

  /// Check if user is waiting for a random buddy
  Future<bool> isWaitingForBuddy({
    required String userId,
    required String challengeId,
  }) async {
    final waitingDocs = await _firestore
        .collection(_waitingQueueCollection)
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .get();

    return waitingDocs.docs.isNotEmpty;
  }

  // ============================================================================
  // Accept/Decline Buddy Invites
  // ============================================================================

  /// Accept a buddy invite
  Future<ChallengeBuddy> acceptBuddyInvite(String buddyId) async {
    final buddy = _buddies.get(buddyId);
    if (buddy == null) {
      // Try to get from Firestore
      final doc = await _firestore.collection(_buddiesCollection).doc(buddyId).get();
      if (!doc.exists) {
        throw BuddyException('Buddy invite not found');
      }
      // Parse and save locally first
      final remoteBuddy = ChallengeBuddy.fromFirestore(doc);
      await _buddies.put(remoteBuddy.id, remoteBuddy);
      return await _acceptBuddy(remoteBuddy);
    }

    return await _acceptBuddy(buddy);
  }

  Future<ChallengeBuddy> _acceptBuddy(ChallengeBuddy buddy) async {
    if (!buddy.isPending) {
      throw BuddyException('Buddy invite is not pending');
    }

    final now = DateTime.now();
    final updated = buddy.copyWith(
      status: BuddyStatus.active,
      startDate: now,
      updatedAt: now,
    );

    // Save locally
    await _buddies.put(updated.id, updated);

    // Update Firestore
    await _firestore.collection(_buddiesCollection).doc(updated.id).update({
      'status': 'active',
      'startDate': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    return updated;
  }

  /// Decline a buddy invite
  Future<ChallengeBuddy> declineBuddyInvite(String buddyId) async {
    final buddy = _buddies.get(buddyId);
    if (buddy == null) {
      throw BuddyException('Buddy invite not found');
    }

    if (!buddy.isPending) {
      throw BuddyException('Buddy invite is not pending');
    }

    final now = DateTime.now();
    final updated = buddy.copyWith(
      status: BuddyStatus.declined,
      updatedAt: now,
    );

    // Save locally
    await _buddies.put(updated.id, updated);

    // Update Firestore
    await _firestore.collection(_buddiesCollection).doc(updated.id).update({
      'status': 'declined',
      'updatedAt': Timestamp.fromDate(now),
    });

    return updated;
  }

  // ============================================================================
  // Progress Tracking
  // ============================================================================

  /// Update progress for a user in a buddy challenge
  Future<ChallengeBuddy> updateProgress({
    required String buddyId,
    required String userId,
    required int progress,
  }) async {
    final buddy = _buddies.get(buddyId);
    if (buddy == null) {
      throw BuddyException('Buddy relationship not found');
    }

    if (!buddy.isActive) {
      throw BuddyException('Buddy challenge is not active');
    }

    final now = DateTime.now();
    final isUser1 = buddy.userId1 == userId;
    final updated = buddy.copyWith(
      user1Progress: isUser1 ? progress : null,
      user2Progress: !isUser1 ? progress : null,
      updatedAt: now,
    );

    // Save locally
    await _buddies.put(updated.id, updated);

    // Update Firestore
    await _firestore.collection(_buddiesCollection).doc(updated.id).update({
      isUser1 ? 'user1Progress' : 'user2Progress': progress,
      'updatedAt': Timestamp.fromDate(now),
    });

    return updated;
  }

  /// Mark challenge as completed
  Future<ChallengeBuddy> completeChallenge(String buddyId) async {
    final buddy = _buddies.get(buddyId);
    if (buddy == null) {
      throw BuddyException('Buddy relationship not found');
    }

    final now = DateTime.now();
    final updated = buddy.copyWith(
      status: BuddyStatus.completed,
      updatedAt: now,
    );

    await _buddies.put(updated.id, updated);

    await _firestore.collection(_buddiesCollection).doc(updated.id).update({
      'status': 'completed',
      'updatedAt': Timestamp.fromDate(now),
    });

    return updated;
  }

  // ============================================================================
  // Query Operations
  // ============================================================================

  /// Get all active buddy challenges for a user
  List<ChallengeBuddy> getActiveBuddies(String userId) {
    return _buddies.values
        .where((b) => b.isActive && b.isUser(userId))
        .toList();
  }

  /// Get pending buddy invites received by a user
  List<ChallengeBuddy> getPendingInvites(String userId) {
    return _buddies.values
        .where((b) => b.isPending && b.userId2 == userId)
        .toList();
  }

  /// Get pending buddy invites sent by a user
  List<ChallengeBuddy> getSentInvites(String userId) {
    return _buddies.values
        .where((b) => b.isPending && b.userId1 == userId)
        .toList();
  }

  /// Get buddy for a specific challenge
  ChallengeBuddy? getBuddyForChallenge(String userId, String challengeId) {
    try {
      return _buddies.values.firstWhere(
        (b) => b.challengeId == challengeId &&
               b.isUser(userId) &&
               (b.isActive || b.isPending),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all completed buddy challenges
  List<ChallengeBuddy> getCompletedBuddies(String userId) {
    return _buddies.values
        .where((b) => b.isCompleted && b.isUser(userId))
        .toList();
  }

  /// Sync buddy data from Firestore (call on app start)
  Future<void> syncFromFirestore(String userId) async {
    // Get all buddies where user is involved
    final query1 = await _firestore
        .collection(_buddiesCollection)
        .where('userId1', isEqualTo: userId)
        .get();

    final query2 = await _firestore
        .collection(_buddiesCollection)
        .where('userId2', isEqualTo: userId)
        .get();

    final allDocs = [...query1.docs, ...query2.docs];

    for (final doc in allDocs) {
      final buddy = ChallengeBuddy.fromFirestore(doc);
      await _buddies.put(buddy.id, buddy);
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Find existing buddy relationship between two users for a challenge
  ChallengeBuddy? _findExistingBuddy(String userId1, String userId2, String challengeId) {
    try {
      return _buddies.values.firstWhere((b) =>
          b.challengeId == challengeId &&
          ((b.userId1 == userId1 && b.userId2 == userId2) ||
           (b.userId1 == userId2 && b.userId2 == userId1)));
    } catch (e) {
      return null;
    }
  }

  /// Get user by ID
  User? getUser(String userId) {
    return _users.get(userId);
  }

  /// Get buddy user for a challenge buddy relationship
  User? getBuddyUser(ChallengeBuddy buddy, String currentUserId) {
    final buddyId = buddy.getBuddyId(currentUserId);
    return _users.get(buddyId);
  }

  /// Get count of active buddy challenges
  int getActiveBuddyCount(String userId) {
    return getActiveBuddies(userId).length;
  }

  /// Get count of pending invites
  int getPendingInviteCount(String userId) {
    return getPendingInvites(userId).length;
  }

  /// Leave/remove a buddy relationship
  Future<void> leaveBuddyChallenge(String buddyId) async {
    await _buddies.delete(buddyId);
    await _firestore.collection(_buddiesCollection).doc(buddyId).delete();
  }
}

/// Custom exception for buddy operations
class BuddyException implements Exception {
  final String message;
  BuddyException(this.message);

  @override
  String toString() => 'BuddyException: $message';
}
