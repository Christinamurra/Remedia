import 'package:hive/hive.dart';
import 'meal_slot.dart';

part 'meal_plan.g.dart';

@HiveType(typeId: 2)
class MealPlan {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime weekStartDate; // Always Monday

  @HiveField(2)
  final List<MealSlot> slots; // 28 slots (7 days × 4 meal types)

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  MealPlan({
    required this.id,
    required this.weekStartDate,
    required this.slots,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));

  int get totalMealsPlanned => slots.where((slot) => slot.isFilled).length;

  int get totalSlots => slots.length;

  double get completionPercentage =>
      totalSlots > 0 ? (totalMealsPlanned / totalSlots) * 100 : 0.0;

  int get totalMealsLogged => slots.where((slot) => slot.isLogged).length;

  // Helper methods
  List<MealSlot> getMealSlotsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return slots
        .where((slot) {
          final slotDateOnly =
              DateTime(slot.date.year, slot.date.month, slot.date.day);
          return slotDateOnly == dateOnly;
        })
        .toList()
      ..sort((a, b) => a.mealType.sortOrder.compareTo(b.mealType.sortOrder));
  }

  MealSlot? getMealSlot(DateTime date, MealType mealType) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    try {
      return slots.firstWhere(
        (slot) {
          final slotDateOnly =
              DateTime(slot.date.year, slot.date.month, slot.date.day);
          return slotDateOnly == dateOnly && slot.mealType == mealType;
        },
      );
    } catch (e) {
      return null;
    }
  }

  // Get all slots grouped by date
  Map<DateTime, List<MealSlot>> get slotsByDate {
    final Map<DateTime, List<MealSlot>> grouped = {};

    for (var slot in slots) {
      final dateOnly = DateTime(slot.date.year, slot.date.month, slot.date.day);
      grouped.putIfAbsent(dateOnly, () => []);
      grouped[dateOnly]!.add(slot);
    }

    // Sort slots within each date by meal type
    for (var dateSlots in grouped.values) {
      dateSlots.sort((a, b) => a.mealType.sortOrder.compareTo(b.mealType.sortOrder));
    }

    return grouped;
  }

  // Get sorted dates for the week
  List<DateTime> get weekDates {
    return List.generate(7, (index) {
      final date = weekStartDate.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });
  }

  // Factory: Create empty meal plan for a week
  factory MealPlan.empty({required DateTime weekStartDate}) {
    final now = DateTime.now();
    final slots = <MealSlot>[];

    // Create 28 empty slots (7 days × 4 meal types)
    for (int day = 0; day < 7; day++) {
      final date = weekStartDate.add(Duration(days: day));

      for (var mealType in MealType.values) {
        slots.add(MealSlot.empty(
          date: date,
          mealType: mealType,
        ));
      }
    }

    return MealPlan(
      id: weekStartDate.toIso8601String(),
      weekStartDate: weekStartDate,
      slots: slots,
      createdAt: now,
      updatedAt: now,
    );
  }

  // CopyWith method
  MealPlan copyWith({
    String? id,
    DateTime? weekStartDate,
    List<MealSlot>? slots,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      slots: slots ?? this.slots,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update a specific slot
  MealPlan updateSlot(MealSlot updatedSlot) {
    final updatedSlots = slots.map((slot) {
      if (slot.id == updatedSlot.id) {
        return updatedSlot;
      }
      return slot;
    }).toList();

    return copyWith(
      slots: updatedSlots,
      updatedAt: DateTime.now(),
    );
  }

  // Add recipe to a slot
  MealPlan addRecipeToSlot({
    required DateTime date,
    required MealType mealType,
    required String recipeId,
    int servings = 1,
  }) {
    final slot = getMealSlot(date, mealType);
    if (slot == null) return this;

    final updatedSlot = slot.assignRecipe(recipeId, servings: servings);
    return updateSlot(updatedSlot);
  }

  // Remove recipe from a slot
  MealPlan removeRecipeFromSlot({
    required DateTime date,
    required MealType mealType,
  }) {
    final slot = getMealSlot(date, mealType);
    if (slot == null) return this;

    final updatedSlot = slot.clear();
    return updateSlot(updatedSlot);
  }

  // Update servings for a slot
  MealPlan updateSlotServings({
    required DateTime date,
    required MealType mealType,
    required int servings,
  }) {
    final slot = getMealSlot(date, mealType);
    if (slot == null) return this;

    final updatedSlot = slot.updateServings(servings);
    return updateSlot(updatedSlot);
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekStartDate': weekStartDate.toIso8601String(),
      'slots': slots.map((slot) => slot.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'] as String,
      weekStartDate: DateTime.parse(map['weekStartDate'] as String),
      slots: (map['slots'] as List)
          .map((slotMap) => MealSlot.fromMap(slotMap as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'MealPlan(id: $id, weekStartDate: $weekStartDate, totalMealsPlanned: $totalMealsPlanned/$totalSlots)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MealPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
