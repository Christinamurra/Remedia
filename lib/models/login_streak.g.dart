// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_streak.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginStreakAdapter extends TypeAdapter<LoginStreak> {
  @override
  final int typeId = 7;

  @override
  LoginStreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginStreak(
      currentStreak: fields[0] as int,
      longestStreak: fields[1] as int,
      lastLoginDate: fields[2] as DateTime,
      streakStartDate: fields[3] as DateTime,
      totalDaysLoggedIn: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LoginStreak obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.longestStreak)
      ..writeByte(2)
      ..write(obj.lastLoginDate)
      ..writeByte(3)
      ..write(obj.streakStartDate)
      ..writeByte(4)
      ..write(obj.totalDaysLoggedIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginStreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
