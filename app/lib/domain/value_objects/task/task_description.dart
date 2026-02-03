/// TaskDescription - タスクの説明を表現する ValueObject
///
/// バリデーション：1～500文字、空白のみ不可
import 'package:hive/hive.dart';

part 'task_description.g.dart';

@HiveType(typeId: 32)
class TaskDescription {
  static const int maxLength = 500;
  @HiveField(0)
  late String value;

  TaskDescription([String? val]) {
    if (val == null) {
      value = '';
    } else {
      value = val;
      _validate();
    }
  }

  void _validate() {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError(
        'TaskDescription must be between 1 and $maxLength characters (trimmed), got: "${value.length}"',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDescription &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TaskDescription($value)';
}
