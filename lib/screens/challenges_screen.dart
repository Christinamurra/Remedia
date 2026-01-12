import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../theme/remedia_theme.dart';
import '../models/challenge.dart';
import '../models/challenge_buddy.dart';
import '../models/user.dart';
import '../services/challenge_buddy_service.dart';
import '../services/friend_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<Challenge> _challenges = List.from(sampleChallenges);
  final ChallengeBuddyService _buddyService = ChallengeBuddyService();
  final FriendService _friendService = FriendService();

  // Completed days per challenge (challenge index -> set of completed day numbers)
  // Starts empty - users will check off days as they complete them
  final Map<int, Set<int>> _completedDaysPerChallenge = {};

  // Buddy info per challenge (challenge id -> buddy)
  final Map<String, ChallengeBuddy> _challengeBuddies = {};

  // Waiting for random buddy
  final Set<String> _waitingForBuddy = {};

  // Pending buddy invites received
  List<ChallengeBuddy> _pendingInvites = [];

  String? get _currentUserId => fb_auth.FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadBuddies();
  }

  Future<void> _loadBuddies() async {
    if (_currentUserId == null) return;

    // Sync from Firestore
    await _buddyService.syncFromFirestore(_currentUserId!);

    // Get active buddies
    final buddies = _buddyService.getActiveBuddies(_currentUserId!);
    setState(() {
      for (final buddy in buddies) {
        _challengeBuddies[buddy.challengeId] = buddy;
      }
    });

    // Get pending invites
    final invites = _buddyService.getPendingInvites(_currentUserId!);
    setState(() {
      _pendingInvites = invites;
    });

    // Check if waiting for any buddies
    for (final challenge in _challenges) {
      final isWaiting = await _buddyService.isWaitingForBuddy(
        userId: _currentUserId!,
        challengeId: challenge.id,
      );
      if (isWaiting) {
        setState(() => _waitingForBuddy.add(challenge.id));
      }
    }
  }

  void _toggleChallenge(int index) async {
    final challenge = _challenges[index];

    // If pausing, just pause
    if (challenge.isActive) {
      setState(() {
        _challenges[index] = challenge.copyWith(
          isActive: false,
          currentStreak: 0,
          startDate: null,
        );
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${challenge.title} paused.'),
          backgroundColor: RemediaColors.mutedGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Starting a new challenge - show buddy dialog first
    final buddyChoice = await _showBuddyChoiceDialog(challenge);
    if (buddyChoice == null) return; // User cancelled

    Map<String, int>? fastingResult;
    // If fasting challenge, show time picker
    if (challenge.type == ChallengeType.fasting) {
      fastingResult = await _showEatingWindowDialog(challenge);
      if (fastingResult == null) return; // User cancelled
    }

    // Start the challenge
    setState(() {
      _challenges[index] = challenge.copyWith(
        isActive: true,
        currentStreak: 1,
        startDate: DateTime.now(),
        eatingWindowStart: fastingResult?['start'],
        eatingWindowEnd: fastingResult?['end'],
      );
    });

    if (!mounted) return;

    String message = '${challenge.title} started! Day 1 begins now.';
    if (buddyChoice == 'waiting') {
      message = '${challenge.title} started! Looking for a buddy...';
    } else if (buddyChoice == 'matched') {
      message = '${challenge.title} started! You have a buddy!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: RemediaColors.mutedGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<String?> _showBuddyChoiceDialog(Challenge challenge) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: RemediaColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RemediaColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start ${challenge.title}',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Would you like to do this challenge with a buddy?',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Solo option
              _buildBuddyOption(
                icon: Icons.person,
                title: 'Go Solo',
                subtitle: 'Complete the challenge on your own',
                onTap: () => Navigator.pop(context, 'solo'),
              ),
              const SizedBox(height: 12),

              // Find a friend option
              _buildBuddyOption(
                icon: Icons.group,
                title: 'Invite a Friend',
                subtitle: 'Ask a friend to join you',
                onTap: () async {
                  Navigator.pop(context);
                  final result = await _showFriendPickerDialog(challenge);
                  if (result != null && mounted) {
                    Navigator.of(this.context).pop(result);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Random buddy option
              _buildBuddyOption(
                icon: Icons.shuffle,
                title: 'Find a Random Buddy',
                subtitle: 'Get matched with someone anonymously',
                onTap: () async {
                  Navigator.pop(context);
                  await _findRandomBuddy(challenge);
                },
                isHighlighted: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBuddyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? RemediaColors.mutedGreen.withValues(alpha: 0.1)
              : RemediaColors.warmBeige,
          borderRadius: BorderRadius.circular(12),
          border: isHighlighted
              ? Border.all(color: RemediaColors.mutedGreen, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? RemediaColors.mutedGreen
                    : RemediaColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isHighlighted ? Colors.white : RemediaColors.textDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: RemediaColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showFriendPickerDialog(Challenge challenge) async {
    if (_currentUserId == null) return null;

    final friends = await _friendService.getFriendUsers(_currentUserId!);

    if (friends.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add some friends first to invite them to challenges!'),
          backgroundColor: RemediaColors.terraCotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return 'solo';
    }

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: RemediaColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RemediaColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Invite a Friend',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a friend to do ${challenge.title} together',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: RemediaColors.mutedGreen,
                        child: Text(
                          friend.initials,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        friend.displayName,
                        style: TextStyle(
                          color: RemediaColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await _inviteFriend(challenge, friend);
                          if (context.mounted) {
                            Navigator.pop(context, 'invited');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RemediaColors.mutedGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Invite',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _inviteFriend(Challenge challenge, User friend) async {
    if (_currentUserId == null) return;

    try {
      final buddy = await _buddyService.inviteFriend(
        userId: _currentUserId!,
        friendId: friend.id,
        challenge: challenge,
      );

      setState(() {
        _challengeBuddies[challenge.id] = buddy;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invited ${friend.displayName} to ${challenge.title}!'),
          backgroundColor: RemediaColors.mutedGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to invite: $e'),
          backgroundColor: RemediaColors.terraCotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<String?> _findRandomBuddy(Challenge challenge) async {
    if (_currentUserId == null) return null;

    try {
      final buddy = await _buddyService.findRandomBuddy(
        userId: _currentUserId!,
        challenge: challenge,
      );

      if (buddy != null) {
        // Found a match!
        setState(() {
          _challengeBuddies[challenge.id] = buddy;
          _waitingForBuddy.remove(challenge.id);
        });

        if (!mounted) return 'matched';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Found a buddy! You\'re matched for this challenge.'),
            backgroundColor: RemediaColors.mutedGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return 'matched';
      } else {
        // Added to waiting queue
        setState(() {
          _waitingForBuddy.add(challenge.id);
        });

        if (!mounted) return 'waiting';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Looking for a buddy... You\'ll be matched soon!'),
            backgroundColor: RemediaColors.waterBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return 'waiting';
      }
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error finding buddy: $e'),
          backgroundColor: RemediaColors.terraCotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return null;
    }
  }

  Future<Map<String, int>?> _showEatingWindowDialog(Challenge challenge) async {
    int startHour = challenge.eatingWindowStart ?? 12;
    int endHour = challenge.eatingWindowEnd ?? 20;

    return showDialog<Map<String, int>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final eatingHours = endHour > startHour
                ? endHour - startHour
                : 24 - startHour + endHour;
            final fastingHours = 24 - eatingHours;

            return AlertDialog(
              backgroundColor: RemediaColors.creamBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Set Your Eating Window',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose when you want to eat each day',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Start Eating',
                              style: TextStyle(
                                color: RemediaColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: RemediaColors.warmBeige,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<int>(
                                value: startHour,
                                underline: const SizedBox(),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                isExpanded: true,
                                items: List.generate(24, (i) => i).map((hour) {
                                  return DropdownMenuItem(
                                    value: hour,
                                    child: Text(Challenge.formatHour(hour)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() => startHour = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Stop Eating',
                              style: TextStyle(
                                color: RemediaColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: RemediaColors.warmBeige,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<int>(
                                value: endHour,
                                underline: const SizedBox(),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                isExpanded: true,
                                items: List.generate(24, (i) => i).map((hour) {
                                  return DropdownMenuItem(
                                    value: hour,
                                    child: Text(Challenge.formatHour(hour)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() => endHour = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RemediaColors.waterBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$fastingHours:$eatingHours',
                          style: TextStyle(
                            color: RemediaColors.waterBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'fasting:eating',
                          style: TextStyle(
                            color: RemediaColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: RemediaColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {'start': startHour, 'end': endHour});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RemediaColors.mutedGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Challenge',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Pending buddy invites
              _buildPendingBuddyInvites(),

              // Active challenge summary
              _buildActiveSummary(),
              const SizedBox(height: 24),

              // Add Challenge Dropdown Button
              _buildAddChallengeButton(),

              // Challenge cards
              Text(
                'Your Active Challenges',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Show only active challenges or empty state
              if (_challenges.where((c) => c.isActive).isEmpty)
                _buildEmptyState()
              else
                ..._challenges.where((c) => c.isActive).map((challenge) {
                  final index = _challenges.indexOf(challenge);
                  return _buildChallengeCard(challenge, index);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Challenges',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Do challenges with your buddies',
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingBuddyInvites() {
    if (_pendingInvites.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buddy Invites',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._pendingInvites.map((invite) {
          final senderUser = _buddyService.getUser(invite.userId1);
          final senderName = senderUser?.displayName ?? 'Someone';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RemediaColors.waterBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RemediaColors.waterBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: RemediaColors.waterBlue,
                      child: Text(
                        senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$senderName invited you!',
                            style: TextStyle(
                              color: RemediaColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            invite.challengeTitle,
                            style: TextStyle(
                              color: RemediaColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _declineBuddyInvite(invite),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: RemediaColors.terraCotta,
                          side: BorderSide(color: RemediaColors.terraCotta),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptBuddyInvite(invite),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RemediaColors.mutedGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _acceptBuddyInvite(ChallengeBuddy invite) async {
    try {
      final updatedBuddy = await _buddyService.acceptBuddyInvite(invite.id);

      setState(() {
        _pendingInvites.removeWhere((i) => i.id == invite.id);
        _challengeBuddies[updatedBuddy.challengeId] = updatedBuddy;
      });

      // Activate the challenge if not already active
      final challengeIndex = _challenges.indexWhere((c) => c.id == invite.challengeId);
      if (challengeIndex >= 0 && !_challenges[challengeIndex].isActive) {
        setState(() {
          _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
            isActive: true,
            currentStreak: 1,
            startDate: DateTime.now(),
          );
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You\'re now buddies for ${invite.challengeTitle}!'),
          backgroundColor: RemediaColors.mutedGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting invite: $e'),
          backgroundColor: RemediaColors.terraCotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _declineBuddyInvite(ChallengeBuddy invite) async {
    try {
      await _buddyService.declineBuddyInvite(invite.id);

      setState(() {
        _pendingInvites.removeWhere((i) => i.id == invite.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invite declined'),
          backgroundColor: RemediaColors.textMuted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error declining invite: $e'),
          backgroundColor: RemediaColors.terraCotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildActiveSummary() {
    final activeCount = _challenges.where((c) => c.isActive).length;
    final totalStreak = _challenges.fold<int>(0, (sum, c) => sum + c.currentStreak);
    final totalCompletedDays = _completedDaysPerChallenge.values
        .fold<int>(0, (sum, days) => sum + days.length);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.mutedGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '$activeCount',
              'Active\nChallenges',
              '🎯',
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '$totalStreak',
              'Day\nStreak',
              '🔥',
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '$totalCompletedDays',
              'Days\nCompleted',
              '✅',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, String emoji) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }


  Widget _buildDayTracker(int challengeIndex, int totalDays) {
    final completedDays = _completedDaysPerChallenge[challengeIndex] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '30-Day Tracker',
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(totalDays, (index) {
            final dayNumber = index + 1;
            final isCompleted = completedDays.contains(dayNumber);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (!_completedDaysPerChallenge.containsKey(challengeIndex)) {
                    _completedDaysPerChallenge[challengeIndex] = {};
                  }
                  if (isCompleted) {
                    _completedDaysPerChallenge[challengeIndex]!.remove(dayNumber);
                  } else {
                    _completedDaysPerChallenge[challengeIndex]!.add(dayNumber);
                  }
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? RemediaColors.mutedGreen
                      : RemediaColors.warmBeige,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCompleted
                        ? RemediaColors.mutedGreen
                        : RemediaColors.textMuted.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: RemediaColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAddChallengeButton() {
    final availableChallenges = _challenges.where((c) => !c.isActive).toList();

    if (availableChallenges.isEmpty) {
      return const SizedBox(); // Hide button if all challenges are active
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: PopupMenuButton<Challenge>(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: RemediaColors.mutedGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Add Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        itemBuilder: (context) {
          return availableChallenges.map((challenge) {
            return PopupMenuItem<Challenge>(
              value: challenge,
              child: Row(
                children: [
                  Text(challenge.iconEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        onSelected: (challenge) {
          final index = _challenges.indexOf(challenge);
          _toggleChallenge(index); // Activate the challenge
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No active challenges',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Challenge" above to start your wellness journey!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, int index) {
    final Color accentColor;
    switch (challenge.type) {
      case ChallengeType.raw:
        accentColor = RemediaColors.mutedGreen;
        break;
      case ChallengeType.sugarDetox:
        accentColor = RemediaColors.terraCotta;
        break;
      case ChallengeType.fasting:
        accentColor = RemediaColors.waterBlue;
        break;
      case ChallengeType.oilFree:
        accentColor = const Color(0xFF9B8B7A); // Warm taupe
        break;
      case ChallengeType.noSugar:
        accentColor = const Color(0xFFE8A87C); // Soft peach
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header with emoji and title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      challenge.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          color: RemediaColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.type == ChallengeType.fasting && challenge.isActive
                            ? '${challenge.fastingHours}:${24 - challenge.fastingHours} fasting window'
                            : challenge.subtitle,
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (challenge.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Day ${challenge.currentStreak}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.description,
                  style: TextStyle(
                    color: RemediaColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                // Show eating window for fasting challenges
                if (challenge.type == ChallengeType.fasting && challenge.isActive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RemediaColors.waterBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: RemediaColors.waterBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${challenge.fastingHours}:${24 - challenge.fastingHours} Fasting Window',
                                style: TextStyle(
                                  color: RemediaColors.waterBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                challenge.eatingWindowDescription,
                                style: TextStyle(
                                  color: RemediaColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await _showEatingWindowDialog(challenge);
                            if (result != null) {
                              setState(() {
                                _challenges[index] = challenge.copyWith(
                                  eatingWindowStart: result['start'],
                                  eatingWindowEnd: result['end'],
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: RemediaColors.waterBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: RemediaColors.waterBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Progress bar (if active)
          if (challenge.isActive) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${challenge.currentStreak}/${challenge.totalDays} days',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      backgroundColor: RemediaColors.warmBeige,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Buddy section
          if (challenge.isActive) ...[
            _buildBuddySection(challenge),
          ],

          // Day tracker
          if (challenge.isActive) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDayTracker(index, challenge.totalDays),
            ),
          ],

          // Action button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _toggleChallenge(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: challenge.isActive
                      ? RemediaColors.warmBeige
                      : accentColor,
                  foregroundColor: challenge.isActive
                      ? RemediaColors.textDark
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Text(
                  challenge.isActive ? 'Pause Challenge' : 'Start Challenge',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddySection(Challenge challenge) {
    final buddy = _challengeBuddies[challenge.id];
    final isWaiting = _waitingForBuddy.contains(challenge.id);

    if (buddy == null && !isWaiting) {
      // No buddy, show option to add one
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () => _showAddBuddyDialog(challenge),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RemediaColors.warmBeige,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: RemediaColors.textMuted.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: RemediaColors.mutedGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: RemediaColors.mutedGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a Buddy',
                        style: TextStyle(
                          color: RemediaColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Do this challenge with a friend!',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: RemediaColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isWaiting) {
      // Waiting for a random buddy
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: RemediaColors.waterBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: RemediaColors.waterBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Looking for a Buddy...',
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'You\'ll be matched with someone soon!',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _buddyService.cancelRandomBuddySearch(
                    userId: _currentUserId!,
                    challengeId: challenge.id,
                  );
                  setState(() {
                    _waitingForBuddy.remove(challenge.id);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: RemediaColors.terraCotta.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: RemediaColors.terraCotta,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Has a buddy - show buddy info
    final buddyUser = _buddyService.getBuddyUser(buddy!, _currentUserId!);
    final buddyName = buddy.matchType == BuddyMatchType.random
        ? 'Anonymous Buddy'
        : (buddyUser?.displayName ?? 'Buddy');
    final buddyProgress = buddy.getBuddyProgress(_currentUserId!);
    final myProgress = buddy.getMyProgress(_currentUserId!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              RemediaColors.mutedGreen.withValues(alpha: 0.1),
              RemediaColors.mutedGreen.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: RemediaColors.mutedGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Challenge Buddy',
                  style: TextStyle(
                    color: RemediaColors.mutedGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (buddy.matchType == BuddyMatchType.random) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: RemediaColors.waterBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Random Match',
                      style: TextStyle(
                        color: RemediaColors.waterBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // My progress
                Expanded(
                  child: _buildBuddyProgressItem(
                    name: 'You',
                    progress: myProgress,
                    totalDays: _challenges
                        .firstWhere((c) => c.id == challenge.id)
                        .totalDays,
                    isMe: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
                ),
                // Buddy progress
                Expanded(
                  child: _buildBuddyProgressItem(
                    name: buddyName,
                    progress: buddyProgress,
                    totalDays: _challenges
                        .firstWhere((c) => c.id == challenge.id)
                        .totalDays,
                    isMe: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuddyProgressItem({
    required String name,
    required int progress,
    required int totalDays,
    required bool isMe,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isMe
              ? RemediaColors.mutedGreen
              : RemediaColors.waterBlue,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name.length > 10 ? '${name.substring(0, 10)}...' : name,
          style: TextStyle(
            color: RemediaColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$progress/$totalDays days',
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _showAddBuddyDialog(Challenge challenge) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: RemediaColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RemediaColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add a Buddy',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get motivated by doing ${challenge.title} with someone!',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              _buildBuddyOption(
                icon: Icons.group,
                title: 'Invite a Friend',
                subtitle: 'Ask a friend to join you',
                onTap: () async {
                  Navigator.pop(context);
                  await _showFriendPickerDialog(challenge);
                },
              ),
              const SizedBox(height: 12),

              _buildBuddyOption(
                icon: Icons.shuffle,
                title: 'Find a Random Buddy',
                subtitle: 'Get matched with someone anonymously',
                onTap: () async {
                  Navigator.pop(context);
                  await _findRandomBuddy(challenge);
                },
                isHighlighted: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
