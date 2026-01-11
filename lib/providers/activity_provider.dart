import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/login_streak.dart';
import '../models/meal_log.dart';
import '../models/meal_slot.dart';

class ActivityProvider with ChangeNotifier {
  static const String _streakBoxName = 'login_streak';
  static const String _mealLogBoxName = 'meal_logs';
  static const String _streakKey = 'current_streak';

  LoginStreak? _streak;
  List<MealLog> _todaysMeals = [];
  List<MealLog> _recentMeals = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  LoginStreak? get streak => _streak;
  int get currentStreak => _streak?.currentStreak ?? 0;
  int get longestStreak => _streak?.longestStreak ?? 0;
  List<MealLog> get todaysMeals => _todaysMeals;
  List<MealLog> get recentMeals => _recentMeals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Count of meals logged today
  int get mealsLoggedToday => _todaysMeals.length;

  /// Check if user has logged all main meals today (breakfast, lunch, dinner)
  bool get hasLoggedAllMainMeals {
    final types = _todaysMeals.map((m) => m.mealType).toSet();
    return types.contains(MealType.breakfast) &&
        types.contains(MealType.lunch) &&
        types.contains(MealType.dinner);
  }

  /// Initialize and load data
  Future<void> initialize() async {
    await _loadStreak();
    await _loadTodaysMeals();
  }

  /// Record app open - updates streak if needed
  Future<void> recordLogin() async {
    try {
      final box = Hive.box<LoginStreak>(_streakBoxName);

      if (_streak == null) {
        // First time user
        _streak = LoginStreak.initial();
      } else {
        // Existing user - update streak
        _streak = _streak!.recordLogin();
      }

      await box.put(_streakKey, _streak!);
      notifyListeners();

      debugPrint('Login recorded: $_streak');
    } catch (e) {
      _errorMessage = 'Failed to record login: $e';
      debugPrint('Error recording login: $e');
    }
  }

  /// Load streak from Hive
  Future<void> _loadStreak() async {
    try {
      _isLoading = true;
      notifyListeners();

      final box = Hive.box<LoginStreak>(_streakBoxName);
      _streak = box.get(_streakKey);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load streak: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading streak: $e');
    }
  }

  /// Load today's meals
  Future<void> _loadTodaysMeals() async {
    try {
      final box = Hive.box<MealLog>(_mealLogBoxName);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      _todaysMeals = box.values.where((meal) {
        final mealDate = DateTime(
          meal.timestamp.year,
          meal.timestamp.month,
          meal.timestamp.day,
        );
        return mealDate.isAtSameMomentAs(today);
      }).toList();

      // Sort by timestamp
      _todaysMeals.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load meals: $e';
      debugPrint('Error loading meals: $e');
    }
  }

  /// Log a new meal
  Future<MealLog?> logMeal({
    required MealType mealType,
    String? photoPath,
    String? notes,
    List<String>? tags,
    String? scannedProductId,
    String? name,
  }) async {
    try {
      final box = Hive.box<MealLog>(_mealLogBoxName);

      final meal = MealLog.create(
        mealType: mealType,
        photoPath: photoPath,
        notes: notes,
        tags: tags,
        scannedProductId: scannedProductId,
        name: name,
      );

      await box.put(meal.id, meal);
      _todaysMeals.add(meal);
      _todaysMeals.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      notifyListeners();
      return meal;
    } catch (e) {
      _errorMessage = 'Failed to log meal: $e';
      debugPrint('Error logging meal: $e');
      return null;
    }
  }

  /// Delete a meal log
  Future<void> deleteMeal(String mealId) async {
    try {
      final box = Hive.box<MealLog>(_mealLogBoxName);
      await box.delete(mealId);

      _todaysMeals.removeWhere((m) => m.id == mealId);
      _recentMeals.removeWhere((m) => m.id == mealId);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete meal: $e';
      debugPrint('Error deleting meal: $e');
    }
  }

  /// Get meals for a specific date
  Future<List<MealLog>> getMealsForDate(DateTime date) async {
    try {
      final box = Hive.box<MealLog>(_mealLogBoxName);
      final targetDate = DateTime(date.year, date.month, date.day);

      return box.values.where((meal) {
        final mealDate = DateTime(
          meal.timestamp.year,
          meal.timestamp.month,
          meal.timestamp.day,
        );
        return mealDate.isAtSameMomentAs(targetDate);
      }).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      debugPrint('Error getting meals for date: $e');
      return [];
    }
  }

  /// Get recent meals (last 7 days)
  Future<void> loadRecentMeals({int days = 7}) async {
    try {
      final box = Hive.box<MealLog>(_mealLogBoxName);
      final now = DateTime.now();
      final cutoff = now.subtract(Duration(days: days));

      _recentMeals = box.values.where((meal) {
        return meal.timestamp.isAfter(cutoff);
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent meals: $e');
    }
  }

  /// Get count of days with at least one meal logged
  Future<int> getDaysWithMealsLogged({int lastDays = 30}) async {
    try {
      final box = Hive.box<MealLog>(_mealLogBoxName);
      final now = DateTime.now();
      final cutoff = now.subtract(Duration(days: lastDays));

      final datesWithMeals = <String>{};
      for (final meal in box.values) {
        if (meal.timestamp.isAfter(cutoff)) {
          final dateKey =
              '${meal.timestamp.year}-${meal.timestamp.month}-${meal.timestamp.day}';
          datesWithMeals.add(dateKey);
        }
      }

      return datesWithMeals.length;
    } catch (e) {
      debugPrint('Error counting days with meals: $e');
      return 0;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
