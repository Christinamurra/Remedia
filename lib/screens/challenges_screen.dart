import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/challenge.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<Challenge> _challenges = List.from(sampleChallenges);

  // Completed days per challenge (challenge index -> set of completed day numbers)
  // Starts empty - users will check off days as they complete them
  final Map<int, Set<int>> _completedDaysPerChallenge = {};

  void _toggleChallenge(int index) async {
    final challenge = _challenges[index];

    // If starting a fasting challenge, show the time picker dialog
    if (!challenge.isActive && challenge.type == ChallengeType.fasting) {
      final result = await _showEatingWindowDialog(challenge);
      if (result == null) return; // User cancelled

      setState(() {
        _challenges[index] = challenge.copyWith(
          isActive: true,
          currentStreak: 1,
          startDate: DateTime.now(),
          eatingWindowStart: result['start'],
          eatingWindowEnd: result['end'],
        );
      });
    } else {
      setState(() {
        _challenges[index] = challenge.copyWith(
          isActive: !challenge.isActive,
          currentStreak: challenge.isActive ? 0 : 1,
          startDate: challenge.isActive ? null : DateTime.now(),
        );
      });
    }

    if (!mounted) return;

    final updatedChallenge = _challenges[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedChallenge.isActive
              ? '${updatedChallenge.title} started! Day 1 begins now.'
              : '${updatedChallenge.title} paused.',
        ),
        backgroundColor: RemediaColors.mutedGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RemediaColors.warmBeige,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back,
              color: RemediaColors.textDark,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Challenges',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Track your wellness journey',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
}
