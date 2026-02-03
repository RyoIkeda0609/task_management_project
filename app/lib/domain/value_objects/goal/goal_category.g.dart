// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalCategoryAdapter extends TypeAdapter<GoalCategory> {
  @override
  final int typeId = 12;

  @override
  GoalCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalCategory()..value = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, GoalCategory obj) {
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
      other is GoalCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
