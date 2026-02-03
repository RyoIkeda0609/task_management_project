import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_id.g.dart';

/// TaskId - タスクの ID を表現する ValueObject
///
/// UUID v4 による一意の識別子
@HiveType(typeId: 30)
class TaskId {
  @HiveField(0)
  late String value;

  TaskId([String? val]) {
    if (val == null) {
      value = '';
    } else {
      value = val;
    }
  }

  /// 新しい TaskId を自動生成する
  factory TaskId.generate() => TaskId(const Uuid().v4());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TaskId($value)';
}
