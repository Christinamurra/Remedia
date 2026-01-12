// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_buddy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeBuddyAdapter extends TypeAdapter<ChallengeBuddy> {
  @override
  final int typeId = 12;

  @override
  ChallengeBuddy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeBuddy(
      id: fields[0] as String,
      challengeId: fields[1] as String,
      challengeTitle: fields[2] as String,
      userId1: fields[3] as String,
      userId2: fields[4] as String,
      status: fields[5] as BuddyStatus,
      matchType: fields[6] as BuddyMatchType,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      startDate: fields[9] as DateTime?,
      user1Progress: fields[10] as int,
      user2Progress: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeBuddy obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.challengeId)
      ..writeByte(2)
      ..write(obj.challengeTitle)
      ..writeByte(3)
      ..write(obj.userId1)
      ..writeByte(4)
      ..write(obj.userId2)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.matchType)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.startDate)
      ..writeByte(10)
      ..write(obj.user1Progress)
      ..writeByte(11)
      ..write(obj.user2Progress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeBuddyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuddyStatusAdapter extends TypeAdapter<BuddyStatus> {
  @override
  final int typeId = 13;

  @override
  BuddyStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuddyStatus.pending;
      case 1:
        return BuddyStatus.active;
      case 2:
        return BuddyStatus.completed;
      case 3:
        return BuddyStatus.declined;
      default:
        return BuddyStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, BuddyStatus obj) {
    switch (obj) {
      case BuddyStatus.pending:
        writer.writeByte(0);
        break;
      case BuddyStatus.active:
        writer.writeByte(1);
        break;
      case BuddyStatus.completed:
        writer.writeByte(2);
        break;
      case BuddyStatus.declined:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuddyStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuddyMatchTypeAdapter extends TypeAdapter<BuddyMatchType> {
  @override
  final int typeId = 14;

  @override
  BuddyMatchType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuddyMatchType.friend;
      case 1:
        return BuddyMatchType.random;
      default:
        return BuddyMatchType.friend;
    }
  }

  @override
  void write(BinaryWriter writer, BuddyMatchType obj) {
    switch (obj) {
      case BuddyMatchType.friend:
        writer.writeByte(0);
        break;
      case BuddyMatchType.random:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuddyMatchTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
