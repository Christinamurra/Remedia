// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealPlanPreferencesAdapter extends TypeAdapter<MealPlanPreferences> {
  @override
  final int typeId = 3;

  @override
  MealPlanPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlanPreferences(
      defaultServings: fields[0] as int,
      showNutritionSummary: fields[1] as bool,
      favoriteMealPlanIds: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MealPlanPreferences obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.defaultServings)
      ..writeByte(1)
      ..write(obj.showNutritionSummary)
      ..writeByte(2)
      ..write(obj.favoriteMealPlanIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
