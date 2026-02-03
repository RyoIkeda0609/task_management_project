// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_description.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskDescriptionAdapter extends TypeAdapter<TaskDescription> {
  @override
  final int typeId = 32;

  @override
  TaskDescription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskDescription()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, TaskDescription obj) {
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
      other is TaskDescriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
