// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_title.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskTitleAdapter extends TypeAdapter<TaskTitle> {
  @override
  final int typeId = 31;

  @override
  TaskTitle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskTitle()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, TaskTitle obj) {
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
      other is TaskTitleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
