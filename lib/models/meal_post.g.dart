// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealPostAdapter extends TypeAdapter<MealPost> {
  @override
  final int typeId = 11;

  @override
  MealPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPost(
      id: fields[0] as String,
      authorId: fields[1] as String,
      imageUrl: fields[2] as String,
      caption: fields[3] as String?,
      linkedRecipeId: fields[4] as String?,
      visibility: fields[5] as MealPostVisibility,
      likedByUserIds: (fields[6] as List).cast<String>(),
      commentsCount: fields[7] as int,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MealPost obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.authorId)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.caption)
      ..writeByte(4)
      ..write(obj.linkedRecipeId)
      ..writeByte(5)
      ..write(obj.visibility)
      ..writeByte(6)
      ..write(obj.likedByUserIds)
      ..writeByte(7)
      ..write(obj.commentsCount)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealPostVisibilityAdapter extends TypeAdapter<MealPostVisibility> {
  @override
  final int typeId = 12;

  @override
  MealPostVisibility read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealPostVisibility.friendsOnly;
      case 1:
        return MealPostVisibility.public;
      default:
        return MealPostVisibility.friendsOnly;
    }
  }

  @override
  void write(BinaryWriter writer, MealPostVisibility obj) {
    switch (obj) {
      case MealPostVisibility.friendsOnly:
        writer.writeByte(0);
        break;
      case MealPostVisibility.public:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPostVisibilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
