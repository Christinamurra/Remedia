import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/recipe.dart';
import '../models/meal_slot.dart';
import '../models/meal_plan.dart';
import '../services/meal_plan_service.dart';

class MealPlanSlotSelectorSheet extends StatefulWidget {
  final Recipe recipe;
  final Function(MealSlot) onSlotSelected;

  const MealPlanSlotSelectorSheet({
    super.key,
    required this.recipe,
    required this.onSlotSelected,
  });

  @override
  State<MealPlanSlotSelectorSheet> createState() =>
      _MealPlanSlotSelectorSheetState();
}

class _MealPlanSlotSelectorSheetState
    extends State<MealPlanSlotSelectorSheet> {
  final MealPlanService _service = MealPlanService();
  MealPlan? _currentWeekPlan;
  MealPlan? _nextWeekPlan;
  bool _isLoading = true;
  bool _showNextWeek = false;

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final nextWeekDate = now.add(const Duration(days: 7));

      final currentPlan = await _service.getMealPlanForWeek(now);
      final nextPlan = await _service.getMealPlanForWeek(nextWeekDate);

      setState(() {
        _currentWeekPlan = currentPlan;
        _nextWeekPlan = nextPlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  MealPlan? get _selectedPlan =>
      _showNextWeek ? _nextWeekPlan : _currentWeekPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: RemediaColors.creamBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RemediaColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add to Meal Plan',
                            style: TextStyle(
                              color: RemediaColors.textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose a day and meal time',
                            style: TextStyle(
                              color: RemediaColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: RemediaColors.textMuted,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Recipe Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RemediaColors.cardLightGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: RemediaColors.mutedGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _getRecipeEmoji(widget.recipe.category),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.recipe.title,
                          style: const TextStyle(
                            color: RemediaColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Week Selector
          if (!_isLoading) _buildWeekSelector(),

          const SizedBox(height: 16),

          // Slot Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedPlan == null
                    ? const Center(child: Text('Unable to load meal plan'))
                    : _buildSlotGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showNextWeek = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showNextWeek
                      ? RemediaColors.mutedGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'This Week',
                  style: TextStyle(
                    color: !_showNextWeek ? Colors.white : RemediaColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showNextWeek = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showNextWeek
                      ? RemediaColors.mutedGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Next Week',
                  style: TextStyle(
                    color: _showNextWeek ? Colors.white : RemediaColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotGrid() {
    final plan = _selectedPlan!;
    final weekDates = plan.weekDates;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: weekDates.length,
      itemBuilder: (context, dayIndex) {
        final date = weekDates[dayIndex];
        final slots = plan.getMealSlotsForDate(date);
        final isToday = _isToday(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Header
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Row(
                children: [
                  Text(
                    _service.getDateWithDayString(date),
                    style: const TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: RemediaColors.mutedGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Meal Slots for this day
            ...slots.map((slot) => _buildSlotCard(slot)),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildSlotCard(MealSlot slot) {
    final isFilled = slot.isFilled;

    return GestureDetector(
      onTap: isFilled ? null : () => _handleSlotSelect(slot),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFilled
              ? RemediaColors.cardSand.withValues(alpha: 0.5)
              : RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFilled
                ? RemediaColors.warmBeige.withValues(alpha: 0.5)
                : RemediaColors.warmBeige,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Meal Type Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isFilled
                    ? RemediaColors.warmBeige.withValues(alpha: 0.5)
                    : RemediaColors.warmBeige,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  slot.mealType.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Meal Type Label
            Expanded(
              child: Text(
                slot.mealType.displayName,
                style: TextStyle(
                  color: isFilled
                      ? RemediaColors.textMuted
                      : RemediaColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Status Icon
            if (isFilled)
              Icon(
                Icons.check_circle_rounded,
                color: RemediaColors.textMuted.withValues(alpha: 0.5),
                size: 20,
              )
            else
              const Icon(
                Icons.add_circle_outline_rounded,
                color: RemediaColors.mutedGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _handleSlotSelect(MealSlot slot) {
    widget.onSlotSelected(slot);
    Navigator.pop(context);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getRecipeEmoji(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.smoothie:
        return '🥤';
      case RecipeCategory.juice:
        return '🧃';
      case RecipeCategory.shot:
        return '🥃';
      case RecipeCategory.bowl:
        return '🥗';
      case RecipeCategory.salad:
        return '🥬';
      case RecipeCategory.soup:
        return '🍲';
      case RecipeCategory.mainDish:
        return '🍽️';
      case RecipeCategory.snack:
        return '🍎';
      case RecipeCategory.dessert:
        return '🍰';
      case RecipeCategory.dressing:
        return '🥗';
      case RecipeCategory.dip:
        return '🥙';
    }
  }
}
