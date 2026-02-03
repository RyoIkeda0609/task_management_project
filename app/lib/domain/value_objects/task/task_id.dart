import 'package:uuid/uuid.dart';

/// TaskId - タスクの ID を表現する ValueObject
///
/// UUID v4 による一意の識別子
class TaskId {
  final String value;

  TaskId(this.value);

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
