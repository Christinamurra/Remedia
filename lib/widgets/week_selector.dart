import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../services/meal_plan_service.dart';

class WeekSelector extends StatelessWidget {
  final DateTime weekStartDate;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToday;
  final bool isCurrentWeek;

  const WeekSelector({
    super.key,
    required this.weekStartDate,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onToday,
    this.isCurrentWeek = false,
  });

  @override
  Widget build(BuildContext context) {
    final service = MealPlanService();
    final weekRangeString = service.getWeekRangeString(weekStartDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Week Button
          IconButton(
            onPressed: onPreviousWeek,
            icon: const Icon(Icons.chevron_left_rounded),
            color: RemediaColors.mutedGreen,
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),

          // Week Range Display
          Expanded(
            child: Column(
              children: [
                Text(
                  weekRangeString,
                  style: const TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isCurrentWeek) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RemediaColors.mutedGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.today_rounded,
                            size: 14,
                            color: RemediaColors.mutedGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Jump to Today',
                            style: TextStyle(
                              color: RemediaColors.mutedGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Next Week Button
          IconButton(
            onPressed: onNextWeek,
            icon: const Icon(Icons.chevron_right_rounded),
            color: RemediaColors.mutedGreen,
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }
}
