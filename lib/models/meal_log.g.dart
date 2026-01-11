// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealLogAdapter extends TypeAdapter<MealLog> {
  @override
  final int typeId = 8;

  @override
  MealLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealLog(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      mealType: fields[2] as MealType,
      photoPath: fields[3] as String?,
      notes: fields[4] as String?,
      tags: (fields[5] as List).cast<String>(),
      scannedProductId: fields[6] as String?,
      name: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.photoPath)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.scannedProductId)
      ..writeByte(7)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
