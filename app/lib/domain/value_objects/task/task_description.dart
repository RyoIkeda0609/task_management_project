/// TaskDescription - タスクの説明を表現する ValueObject
///
/// 任意フィールド。空文字列も許容。
/// Validation は UseCase 側で行う。
class TaskDescription {
  final String value;

  TaskDescription(this.value);

  /// 説明が入力されているかチェック
  bool get isNotEmpty => value.trim().isNotEmpty;

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
