import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';

class MealPlanSummaryCard extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanSummaryCard({
    super.key,
    required this.mealPlan,
  });

  int _getTotalCalories() {
    int total = 0;

    for (var slot in mealPlan.slots) {
      if (slot.isEmpty) continue;

      try {
        final recipe = sampleRecipes.firstWhere(
          (r) => r.id == slot.recipeId,
        );

        // Adjust calories based on servings
        final adjustedCalories =
            (recipe.nutrition.calories * slot.servings / recipe.servings)
                .round();
        total += adjustedCalories;
      } catch (e) {
        // Recipe not found, skip
      }
    }

    return total;
  }

  int _getAverageDailyCalories() {
    final total = _getTotalCalories();
    return total > 0 ? (total / 7).round() : 0;
  }

  @override
  Widget build(BuildContext context) {
    final totalMeals = mealPlan.totalMealsPlanned;
    final totalSlots = mealPlan.totalSlots;
    final avgCalories = _getAverageDailyCalories();
    final completionPercentage = mealPlan.completionPercentage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RemediaColors.cardGlossyHighlight,
            RemediaColors.cardLightGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: RemediaColors.mutedGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Week Summary',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Meals Planned',
                  value: '$totalMeals/$totalSlots',
                  color: RemediaColors.mutedGreen,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.4),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Avg. Daily Cal',
                  value: avgCalories > 0 ? '$avgCalories' : '-',
                  color: RemediaColors.terraCotta,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Week Completion',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${completionPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: RemediaColors.mutedGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    RemediaColors.mutedGreen,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: RemediaColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}
