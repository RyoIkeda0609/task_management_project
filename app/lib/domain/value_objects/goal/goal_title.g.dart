// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_title.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalTitleAdapter extends TypeAdapter<GoalTitle> {
  @override
  final int typeId = 11;

  @override
  GoalTitle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalTitle()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, GoalTitle obj) {
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
      other is GoalTitleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
