import 'package:hive/hive.dart';

part 'meal_plan_preferences.g.dart';

@HiveType(typeId: 3)
class MealPlanPreferences {
  @HiveField(0)
  final int defaultServings;

  @HiveField(1)
  final bool showNutritionSummary;

  @HiveField(2)
  final List<String> favoriteMealPlanIds; // for future "save template" feature

  MealPlanPreferences({
    this.defaultServings = 1,
    this.showNutritionSummary = true,
    this.favoriteMealPlanIds = const [],
  });

  // Factory: Default preferences
  factory MealPlanPreferences.defaults() {
    return MealPlanPreferences(
      defaultServings: 1,
      showNutritionSummary: true,
      favoriteMealPlanIds: [],
    );
  }

  // CopyWith method
  MealPlanPreferences copyWith({
    int? defaultServings,
    bool? showNutritionSummary,
    List<String>? favoriteMealPlanIds,
  }) {
    return MealPlanPreferences(
      defaultServings: defaultServings ?? this.defaultServings,
      showNutritionSummary: showNutritionSummary ?? this.showNutritionSummary,
      favoriteMealPlanIds: favoriteMealPlanIds ?? this.favoriteMealPlanIds,
    );
  }

  // Add a meal plan to favorites
  MealPlanPreferences addFavoritePlan(String planId) {
    if (favoriteMealPlanIds.contains(planId)) {
      return this;
    }

    return copyWith(
      favoriteMealPlanIds: [...favoriteMealPlanIds, planId],
    );
  }

  // Remove a meal plan from favorites
  MealPlanPreferences removeFavoritePlan(String planId) {
    return copyWith(
      favoriteMealPlanIds: favoriteMealPlanIds
          .where((id) => id != planId)
          .toList(),
    );
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'defaultServings': defaultServings,
      'showNutritionSummary': showNutritionSummary,
      'favoriteMealPlanIds': favoriteMealPlanIds,
    };
  }

  factory MealPlanPreferences.fromMap(Map<String, dynamic> map) {
    return MealPlanPreferences(
      defaultServings: map['defaultServings'] as int? ?? 1,
      showNutritionSummary: map['showNutritionSummary'] as bool? ?? true,
      favoriteMealPlanIds: (map['favoriteMealPlanIds'] as List?)
              ?.map((id) => id as String)
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'MealPlanPreferences(defaultServings: $defaultServings, showNutritionSummary: $showNutritionSummary, favorites: ${favoriteMealPlanIds.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MealPlanPreferences &&
        other.defaultServings == defaultServings &&
        other.showNutritionSummary == showNutritionSummary;
  }

  @override
  int get hashCode =>
      defaultServings.hashCode ^ showNutritionSummary.hashCode;
}
