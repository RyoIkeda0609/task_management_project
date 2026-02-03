// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_title.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MilestoneTitleAdapter extends TypeAdapter<MilestoneTitle> {
  @override
  final int typeId = 21;

  @override
  MilestoneTitle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MilestoneTitle()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, MilestoneTitle obj) {
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
      other is MilestoneTitleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
