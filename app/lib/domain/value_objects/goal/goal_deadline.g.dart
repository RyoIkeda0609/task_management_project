// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_deadline.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalDeadlineAdapter extends TypeAdapter<GoalDeadline> {
  @override
  final int typeId = 14;

  @override
  GoalDeadline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalDeadline()..value = fields[0] as DateTime;
  }

  @override
  void write(BinaryWriter writer, GoalDeadline obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalDeadlineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
