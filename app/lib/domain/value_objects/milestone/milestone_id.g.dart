// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_id.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MilestoneIdAdapter extends TypeAdapter<MilestoneId> {
  @override
  final int typeId = 20;

  @override
  MilestoneId read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MilestoneId()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, MilestoneId obj) {
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
      other is MilestoneIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
