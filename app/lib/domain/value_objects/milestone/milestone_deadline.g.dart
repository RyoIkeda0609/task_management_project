// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_deadline.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MilestoneDeadlineAdapter extends TypeAdapter<MilestoneDeadline> {
  @override
  final int typeId = 22;

  @override
  MilestoneDeadline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MilestoneDeadline()..value = fields[0] as DateTime;
  }

  @override
  void write(BinaryWriter writer, MilestoneDeadline obj) {
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
      other is MilestoneDeadlineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
