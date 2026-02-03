// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_id.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalIdAdapter extends TypeAdapter<GoalId> {
  @override
  final int typeId = 10;

  @override
  GoalId read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalId()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, GoalId obj) {
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
      other is GoalIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
