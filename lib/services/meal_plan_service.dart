import 'package:hive/hive.dart';
import '../models/meal_plan.dart';
import '../models/meal_slot.dart';
import '../models/meal_plan_preferences.dart';

class MealPlanService {
  static const String _mealPlansBox = 'meal_plans';
  static const String _mealSlotsBox = 'meal_slots';
  static const String _preferencesBox = 'preferences';
  static const String _preferencesKey = 'meal_plan_prefs';

  // Get Hive boxes
  Box<MealPlan> get _plansBox => Hive.box<MealPlan>(_mealPlansBox);
  Box<MealSlot> get _slotsBox => Hive.box<MealSlot>(_mealSlotsBox);
  Box<MealPlanPreferences> get _prefsBox =>
      Hive.box<MealPlanPreferences>(_preferencesBox);

  // ============================================================================
  // Meal Plan CRUD Operations
  // ============================================================================

  /// Get meal plan for a specific week (creates empty plan if doesn't exist)
  Future<MealPlan> getMealPlanForWeek(DateTime date) async {
    final weekStart = _getWeekStartDate(date);
    final key = _generatePlanKey(weekStart);

    // Try to get existing plan
    final existingPlan = _plansBox.get(key);
    if (existingPlan != null) {
      return existingPlan;
    }

    // Create new empty plan
    final newPlan = MealPlan.empty(weekStartDate: weekStart);
    await saveMealPlan(newPlan);
    return newPlan;
  }

  /// Save or update a meal plan
  Future<void> saveMealPlan(MealPlan plan) async {
    final key = _generatePlanKey(plan.weekStartDate);
    await _plansBox.put(key, plan);

    // Also save individual slots for quick lookup
    for (var slot in plan.slots) {
      final slotKey = _generateSlotKey(slot.date, slot.mealType);
      await _slotsBox.put(slotKey, slot);
    }
  }

  /// Get all meal plans (sorted by week start date, newest first)
  Future<List<MealPlan>> getAllMealPlans() async {
    final plans = _plansBox.values.toList();
    plans.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
    return plans;
  }

  /// Delete a specific meal plan
  Future<void> deleteMealPlan(String weekStartDate) async {
    final key = weekStartDate;
    await _plansBox.delete(key);

    // Also delete associated slots
    final plan = _plansBox.get(key);
    if (plan != null) {
      for (var slot in plan.slots) {
        final slotKey = _generateSlotKey(slot.date, slot.mealType);
        await _slotsBox.delete(slotKey);
      }
    }
  }

  /// Delete old meal plans (older than specified weeks)
  Future<void> cleanupOldMealPlans({int keepWeeks = 12}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: keepWeeks * 7));
    final plans = _plansBox.values.toList();

    for (var plan in plans) {
      if (plan.weekStartDate.isBefore(cutoffDate)) {
        await deleteMealPlan(plan.id);
      }
    }
  }

  // ============================================================================
  // Meal Slot Operations
  // ============================================================================

  /// Add recipe to a specific meal slot
  Future<MealPlan> addRecipeToSlot({
    required DateTime date,
    required MealType mealType,
    required String recipeId,
    int servings = 1,
  }) async {
    final plan = await getMealPlanForWeek(date);
    final updatedPlan = plan.addRecipeToSlot(
      date: date,
      mealType: mealType,
      recipeId: recipeId,
      servings: servings,
    );

    await saveMealPlan(updatedPlan);
    return updatedPlan;
  }

  /// Remove recipe from a specific meal slot
  Future<MealPlan> removeRecipeFromSlot({
    required DateTime date,
    required MealType mealType,
  }) async {
    final plan = await getMealPlanForWeek(date);
    final updatedPlan = plan.removeRecipeFromSlot(
      date: date,
      mealType: mealType,
    );

    await saveMealPlan(updatedPlan);
    return updatedPlan;
  }

  /// Update servings for a specific meal slot
  Future<MealPlan> updateSlotServings({
    required DateTime date,
    required MealType mealType,
    required int servings,
  }) async {
    final plan = await getMealPlanForWeek(date);
    final updatedPlan = plan.updateSlotServings(
      date: date,
      mealType: mealType,
      servings: servings,
    );

    await saveMealPlan(updatedPlan);
    return updatedPlan;
  }

  /// Get a specific meal slot
  Future<MealSlot?> getMealSlot(DateTime date, MealType mealType) async {
    final key = _generateSlotKey(date, mealType);
    return _slotsBox.get(key);
  }

  /// Log a meal as eaten with optional notes
  /// Only allows logging for current week slots
  Future<MealPlan> logMeal({
    required DateTime date,
    required MealType mealType,
    String? notes,
  }) async {
    // Validate: only allow logging for current week
    if (!isCurrentWeek(date)) {
      throw Exception('Can only log meals for the current week');
    }

    final plan = await getMealPlanForWeek(date);
    final slot = plan.getMealSlot(date, mealType);

    if (slot == null) {
      throw Exception('Meal slot not found');
    }

    if (slot.isEmpty) {
      throw Exception('Cannot log an empty meal slot');
    }

    final updatedSlot = slot.logMeal(notes: notes);
    final updatedPlan = plan.updateSlot(updatedSlot);

    await saveMealPlan(updatedPlan);
    return updatedPlan;
  }

  /// Unlog a meal (revert to planned state)
  Future<MealPlan> unlogMeal({
    required DateTime date,
    required MealType mealType,
  }) async {
    final plan = await getMealPlanForWeek(date);
    final slot = plan.getMealSlot(date, mealType);

    if (slot == null) {
      throw Exception('Meal slot not found');
    }

    final updatedSlot = slot.unlogMeal();
    final updatedPlan = plan.updateSlot(updatedSlot);

    await saveMealPlan(updatedPlan);
    return updatedPlan;
  }

  // ============================================================================
  // Preferences Operations
  // ============================================================================

  /// Get user preferences (returns defaults if not set)
  Future<MealPlanPreferences> getPreferences() async {
    final prefs = _prefsBox.get(_preferencesKey);
    return prefs ?? MealPlanPreferences.defaults();
  }

  /// Save user preferences
  Future<void> savePreferences(MealPlanPreferences preferences) async {
    await _prefsBox.put(_preferencesKey, preferences);
  }

  /// Update default servings preference
  Future<void> updateDefaultServings(int servings) async {
    final prefs = await getPreferences();
    final updated = prefs.copyWith(defaultServings: servings);
    await savePreferences(updated);
  }

  /// Toggle nutrition summary visibility
  Future<void> toggleNutritionSummary(bool show) async {
    final prefs = await getPreferences();
    final updated = prefs.copyWith(showNutritionSummary: show);
    await savePreferences(updated);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Get the Monday of the week containing the given date
  DateTime _getWeekStartDate(DateTime date) {
    // Monday = 1, Sunday = 7
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1; // Monday is day 1
    final monday = date.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day); // Remove time component
  }

  /// Generate unique key for meal plan (based on week start date)
  String _generatePlanKey(DateTime weekStartDate) {
    return weekStartDate.toIso8601String();
  }

  /// Generate unique key for meal slot (based on date and meal type)
  String _generateSlotKey(DateTime date, MealType mealType) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return '${dateOnly.toIso8601String()}_${mealType.name}';
  }

  /// Check if a date is in the current week
  bool isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStartDate(now);
    final dateWeekStart = _getWeekStartDate(date);
    return currentWeekStart == dateWeekStart;
  }

  /// Get week range string (e.g., "Dec 30 - Jan 5, 2026")
  String getWeekRangeString(DateTime weekStartDate) {
    final weekEnd = weekStartDate.add(const Duration(days: 6));

    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final startMonth = months[weekStartDate.month];
    final endMonth = months[weekEnd.month];
    final year = weekEnd.year;

    if (weekStartDate.month == weekEnd.month) {
      // Same month: "Dec 30 - 5, 2026"
      return '$startMonth ${weekStartDate.day} - ${weekEnd.day}, $year';
    } else {
      // Different months: "Dec 30 - Jan 5, 2026"
      return '$startMonth ${weekStartDate.day} - $endMonth ${weekEnd.day}, $year';
    }
  }

  /// Get date string with day of week (e.g., "Monday, Dec 30")
  String getDateWithDayString(DateTime date) {
    final days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final dayName = days[date.weekday];
    final month = months[date.month];

    return '$dayName, $month ${date.day}';
  }

  /// Get today's date (without time component)
  DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
