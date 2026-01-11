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
  DateTime _selectedMonth = DateTime.now();

  // Sample completed days for demo
  final Set<int> _completedDays = {1, 2, 3, 4, 5, 8, 9, 10, 11, 12, 15, 16, 17, 18, 19, 22, 23, 24, 25, 26};

  void _toggleChallenge(int index) {
    setState(() {
      _challenges[index] = _challenges[index].copyWith(
        isActive: !_challenges[index].isActive,
        currentStreak: _challenges[index].isActive ? 0 : 1,
        startDate: _challenges[index].isActive ? null : DateTime.now(),
      );
    });

    final challenge = _challenges[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          challenge.isActive
              ? '${challenge.title} started! Day 1 begins now.'
              : '${challenge.title} paused.',
        ),
        backgroundColor: RemediaColors.mutedGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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

              // Calendar
              _buildCalendar(),
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
          'Track your wellness journey',
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSummary() {
    final activeCount = _challenges.where((c) => c.isActive).length;
    final totalStreak = _challenges.fold<int>(0, (sum, c) => sum + c.currentStreak);

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
              '${_completedDays.length}',
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

  Widget _buildCalendar() {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                },
                icon: Icon(Icons.chevron_left, color: RemediaColors.textDark),
              ),
              Text(
                '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                  });
                },
                icon: Icon(Icons.chevron_right, color: RemediaColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              if (dayOffset < 1 || dayOffset > daysInMonth) {
                return const SizedBox();
              }

              final isCompleted = _completedDays.contains(dayOffset);
              final isToday = dayOffset == DateTime.now().day &&
                  _selectedMonth.month == DateTime.now().month &&
                  _selectedMonth.year == DateTime.now().year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_completedDays.contains(dayOffset)) {
                      _completedDays.remove(dayOffset);
                    } else {
                      _completedDays.add(dayOffset);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? RemediaColors.mutedGreen
                        : isToday
                            ? RemediaColors.terraCotta.withValues(alpha: 0.2)
                            : RemediaColors.warmBeige,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: RemediaColors.terraCotta, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '$dayOffset',
                            style: TextStyle(
                              color: isToday
                                  ? RemediaColors.terraCotta
                                  : RemediaColors.textDark,
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(RemediaColors.mutedGreen, 'Completed'),
              const SizedBox(width: 20),
              _buildLegendItem(RemediaColors.terraCotta, 'Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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
                        challenge.subtitle,
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
            child: Text(
              challenge.description,
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
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
