// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScannedProductAdapter extends TypeAdapter<ScannedProduct> {
  @override
  final int typeId = 6;

  @override
  ScannedProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScannedProduct(
      id: fields[0] as String,
      barcode: fields[1] as String?,
      productName: fields[2] as String,
      brand: fields[3] as String?,
      sugarPer100g: fields[4] as double,
      sugarPerServing: fields[5] as double,
      sugarLevel: fields[6] as SugarLevel,
      ingredients: (fields[7] as List).cast<String>(),
      hiddenSugars: (fields[8] as List).cast<String>(),
      imageUrl: fields[9] as String?,
      scannedAt: fields[10] as DateTime,
      userId: fields[11] as String?,
      nutritionFacts: (fields[12] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScannedProduct obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.sugarPer100g)
      ..writeByte(5)
      ..write(obj.sugarPerServing)
      ..writeByte(6)
      ..write(obj.sugarLevel)
      ..writeByte(7)
      ..write(obj.ingredients)
      ..writeByte(8)
      ..write(obj.hiddenSugars)
      ..writeByte(9)
      ..write(obj.imageUrl)
      ..writeByte(10)
      ..write(obj.scannedAt)
      ..writeByte(11)
      ..write(obj.userId)
      ..writeByte(12)
      ..write(obj.nutritionFacts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
