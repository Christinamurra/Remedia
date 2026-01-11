// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommunityPostAdapter extends TypeAdapter<CommunityPost> {
  @override
  final int typeId = 9;

  @override
  CommunityPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunityPost(
      id: fields[0] as String,
      authorId: fields[1] as String,
      anonymousName: fields[2] as String,
      avatar: fields[3] as String,
      content: fields[4] as String,
      imageUrl: fields[5] as String?,
      badge: fields[6] as String?,
      likedByUserIds: (fields[7] as List).cast<String>(),
      commentsCount: fields[8] as int,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      isAnonymous: fields[11] as bool,
      linkedRecipeId: fields[12] as String?,
      tags: (fields[13] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CommunityPost obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.authorId)
      ..writeByte(2)
      ..write(obj.anonymousName)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.badge)
      ..writeByte(7)
      ..write(obj.likedByUserIds)
      ..writeByte(8)
      ..write(obj.commentsCount)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isAnonymous)
      ..writeByte(12)
      ..write(obj.linkedRecipeId)
      ..writeByte(13)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
