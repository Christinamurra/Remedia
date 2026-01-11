import 'package:hive/hive.dart';

part 'meal_slot.g.dart';

@HiveType(typeId: 0)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snack,
}

@HiveType(typeId: 1)
class MealSlot {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final MealType mealType;

  @HiveField(3)
  final String? recipeId; // nullable - slot can be empty

  @HiveField(4)
  final int servings;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final bool isLogged;

  @HiveField(8)
  final String? logNotes;

  @HiveField(9)
  final DateTime? loggedAt;

  MealSlot({
    required this.id,
    required this.date,
    required this.mealType,
    this.recipeId,
    required this.servings,
    required this.createdAt,
    required this.updatedAt,
    this.isLogged = false,
    this.logNotes,
    this.loggedAt,
  });

  // Derived properties
  bool get isEmpty => recipeId == null;
  bool get isFilled => recipeId != null;
  bool get isLoggedWithNotes => isLogged && logNotes != null && logNotes!.isNotEmpty;

  // Create empty slot
  factory MealSlot.empty({
    required DateTime date,
    required MealType mealType,
  }) {
    final now = DateTime.now();
    return MealSlot(
      id: '${date.toIso8601String()}_${mealType.name}',
      date: date,
      mealType: mealType,
      recipeId: null,
      servings: 1,
      createdAt: now,
      updatedAt: now,
      isLogged: false,
      logNotes: null,
      loggedAt: null,
    );
  }

  // CopyWith method for immutability
  MealSlot copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? recipeId,
    int? servings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLogged,
    String? logNotes,
    DateTime? loggedAt,
  }) {
    return MealSlot(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      servings: servings ?? this.servings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLogged: isLogged ?? this.isLogged,
      logNotes: logNotes ?? this.logNotes,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  // Clear recipe from slot (make it empty)
  MealSlot clear() {
    return MealSlot(
      id: id,
      date: date,
      mealType: mealType,
      recipeId: null,
      servings: 1,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isLogged: false,
      logNotes: null,
      loggedAt: null,
    );
  }

  // Assign recipe to slot
  MealSlot assignRecipe(String recipeId, {int? servings}) {
    return copyWith(
      recipeId: recipeId,
      servings: servings ?? this.servings,
      updatedAt: DateTime.now(),
    );
  }

  // Update servings
  MealSlot updateServings(int newServings) {
    return copyWith(
      servings: newServings,
      updatedAt: DateTime.now(),
    );
  }

  // Log meal as eaten with optional notes
  MealSlot logMeal({String? notes}) {
    return copyWith(
      isLogged: true,
      logNotes: notes,
      loggedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Unlog meal (revert to planned state)
  MealSlot unlogMeal() {
    return MealSlot(
      id: id,
      date: date,
      mealType: mealType,
      recipeId: recipeId,
      servings: servings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isLogged: false,
      logNotes: null,
      loggedAt: null,
    );
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType.name,
      'recipeId': recipeId,
      'servings': servings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLogged': isLogged,
      'logNotes': logNotes,
      'loggedAt': loggedAt?.toIso8601String(),
    };
  }

  factory MealSlot.fromMap(Map<String, dynamic> map) {
    return MealSlot(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['mealType'],
      ),
      recipeId: map['recipeId'] as String?,
      servings: map['servings'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isLogged: map['isLogged'] as bool? ?? false,
      logNotes: map['logNotes'] as String?,
      loggedAt: map['loggedAt'] != null
          ? DateTime.parse(map['loggedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'MealSlot(id: $id, date: $date, mealType: $mealType, recipeId: $recipeId, servings: $servings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MealSlot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Helper extension for MealType
extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '🥗';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }

  int get sortOrder {
    switch (this) {
      case MealType.breakfast:
        return 0;
      case MealType.lunch:
        return 1;
      case MealType.dinner:
        return 2;
      case MealType.snack:
        return 3;
    }
  }
}
