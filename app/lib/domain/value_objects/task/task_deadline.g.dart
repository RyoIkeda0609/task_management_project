// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_deadline.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskDeadlineAdapter extends TypeAdapter<TaskDeadline> {
  @override
  final int typeId = 33;

  @override
  TaskDeadline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskDeadline()..value = fields[0] as DateTime;
  }

  @override
  void write(BinaryWriter writer, TaskDeadline obj) {
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
      other is TaskDeadlineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
