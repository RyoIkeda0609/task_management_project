// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_reason.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalReasonAdapter extends TypeAdapter<GoalReason> {
  @override
  final int typeId = 13;

  @override
  GoalReason read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalReason()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, GoalReason obj) {
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
      other is GoalReasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
