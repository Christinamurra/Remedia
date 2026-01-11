import 'package:hive/hive.dart';
import 'meal_slot.dart'; // Reuse MealType enum

part 'meal_log.g.dart';

@HiveType(typeId: 8)
class MealLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final MealType mealType;

  @HiveField(3)
  final String? photoPath;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final List<String> tags;

  @HiveField(6)
  final String? scannedProductId; // Link to a barcode scan if applicable

  @HiveField(7)
  final String? name; // Quick name for the meal (e.g., "Oatmeal with berries")

  MealLog({
    required this.id,
    required this.timestamp,
    required this.mealType,
    this.photoPath,
    this.notes,
    this.tags = const [],
    this.scannedProductId,
    this.name,
  });

  factory MealLog.create({
    required MealType mealType,
    String? photoPath,
    String? notes,
    List<String>? tags,
    String? scannedProductId,
    String? name,
  }) {
    final now = DateTime.now();
    return MealLog(
      id: '${now.millisecondsSinceEpoch}_${mealType.name}',
      timestamp: now,
      mealType: mealType,
      photoPath: photoPath,
      notes: notes,
      tags: tags ?? [],
      scannedProductId: scannedProductId,
      name: name,
    );
  }

  MealLog copyWith({
    String? id,
    DateTime? timestamp,
    MealType? mealType,
    String? photoPath,
    String? notes,
    List<String>? tags,
    String? scannedProductId,
    String? name,
  }) {
    return MealLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      mealType: mealType ?? this.mealType,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      scannedProductId: scannedProductId ?? this.scannedProductId,
      name: name ?? this.name,
    );
  }

  /// Get display name for the meal
  String get displayName => name ?? mealType.displayName;

  /// Check if this meal was logged today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Get the date portion only (no time)
  DateTime get date => DateTime(timestamp.year, timestamp.month, timestamp.day);

  @override
  String toString() {
    return 'MealLog(id: $id, mealType: $mealType, name: $name, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Common tags for meal logging
class MealTags {
  static const String homemade = 'homemade';
  static const String takeout = 'takeout';
  static const String restaurant = 'restaurant';
  static const String healthy = 'healthy';
  static const String treat = 'treat';
  static const String raw = 'raw';
  static const String sugarFree = 'sugar-free';
  static const String oilFree = 'oil-free';
  static const String wholeFood = 'whole-food';
  static const String plantBased = 'plant-based';

  static const List<String> all = [
    homemade,
    takeout,
    restaurant,
    healthy,
    treat,
    raw,
    sugarFree,
    oilFree,
    wholeFood,
    plantBased,
  ];

  static String emoji(String tag) {
    switch (tag) {
      case homemade:
        return '🏠';
      case takeout:
        return '🥡';
      case restaurant:
        return '🍽️';
      case healthy:
        return '💚';
      case treat:
        return '🍰';
      case raw:
        return '🥗';
      case sugarFree:
        return '🚫🍬';
      case oilFree:
        return '🚫🫒';
      case wholeFood:
        return '🌾';
      case plantBased:
        return '🌱';
      default:
        return '🏷️';
    }
  }
}
