import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  int _waterCups = 4;
  final int _waterGoal = 8;
  double _sleepHours = 7.0;
  bool _sugarFree = true;
  int _streak = 7;

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

              // Today's Progress
              _buildTodaysProgress(),
              const SizedBox(height: 24),

              // Water Tracker
              _buildWaterTracker(),
              const SizedBox(height: 20),

              // Sleep Tracker
              _buildSleepTracker(),
              const SizedBox(height: 20),

              // Sugar Free Check
              _buildSugarFreeCheck(),
              const SizedBox(height: 24),

              // Weekly Overview
              _buildWeeklyOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Monitor your daily wellness',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: RemediaColors.terraCotta.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                '$_streak day streak',
                style: TextStyle(
                  color: RemediaColors.terraCotta,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Progress",
            style: TextStyle(
              color: RemediaColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressCircle(
                icon: '💧',
                value: _waterCups / _waterGoal,
                label: '$_waterCups/$_waterGoal cups',
                color: RemediaColors.waterBlue,
              ),
              _buildProgressCircle(
                icon: '🌙',
                value: _sleepHours / 8,
                label: '${_sleepHours.toStringAsFixed(0)}h sleep',
                color: RemediaColors.sleepBrown,
              ),
              _buildProgressCircle(
                icon: _sugarFree ? '✓' : '✗',
                value: _sugarFree ? 1.0 : 0.0,
                label: 'Sugar free',
                color: RemediaColors.successGreen,
                isCheckmark: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle({
    required String icon,
    required double value,
    required String label,
    required Color color,
    bool isCheckmark = false,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: isCheckmark
                    ? Icon(
                        _sugarFree ? Icons.check : Icons.close,
                        color: color,
                        size: 28,
                      )
                    : Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
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

  Widget _buildWaterTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💧', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Water Intake',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$_waterCups of $_waterGoal cups',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(8, (index) {
              final isFilled = index < _waterCups;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _waterCups = index + 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 40,
                    decoration: BoxDecoration(
                      color: isFilled
                          ? RemediaColors.waterBlue
                          : RemediaColors.waterBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  if (_waterCups > 0) setState(() => _waterCups--);
                },
                icon: const Icon(Icons.remove, size: 18),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: RemediaColors.textMuted,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_waterCups < 8) setState(() => _waterCups++);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Cup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RemediaColors.waterBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Sleep',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_sleepHours.toStringAsFixed(1)} hours',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: RemediaColors.sleepBrown,
              inactiveTrackColor: RemediaColors.sleepBrown.withValues(alpha: 0.2),
              thumbColor: RemediaColors.sleepBrown,
              overlayColor: RemediaColors.sleepBrown.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _sleepHours,
              min: 0,
              max: 12,
              divisions: 24,
              onChanged: (value) => setState(() => _sleepHours = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0h', style: TextStyle(color: RemediaColors.textMuted, fontSize: 12)),
              Text('12h', style: TextStyle(color: RemediaColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSugarFreeCheck() {
    return GestureDetector(
      onTap: () => setState(() => _sugarFree = !_sugarFree),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _sugarFree
              ? RemediaColors.successGreen.withValues(alpha: 0.15)
              : RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _sugarFree ? RemediaColors.successGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _sugarFree
                    ? RemediaColors.successGreen
                    : RemediaColors.warmBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _sugarFree ? Icons.check : Icons.close,
                color: _sugarFree ? Colors.white : RemediaColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugar Free Today',
                    style: TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _sugarFree
                        ? 'Amazing! Keep it up!'
                        : 'Tap to mark as sugar free',
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
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // Get current day of week (1 = Monday, 7 = Sunday)
    final today = DateTime.now().weekday - 1; // 0-indexed for our list

    // Past days are "completed" for demo, today depends on _sugarFree toggle
    List<bool> completed = List.generate(7, (index) {
      if (index < today) {
        return true; // Past days shown as completed (demo)
      } else if (index == today) {
        return _sugarFree; // Today depends on sugar-free toggle
      } else {
        return false; // Future days not completed
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Sugar-free days',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isToday = index == today;
              final isCompleted = completed[index];

              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isToday ? RemediaColors.terraCotta : RemediaColors.textMuted,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? RemediaColors.successGreen
                          : RemediaColors.warmBeige,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: RemediaColors.terraCotta, width: 2)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
