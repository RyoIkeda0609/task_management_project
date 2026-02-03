/// TaskStatus - タスクのステータスを表現する ValueObject
///
/// 状態遷移：Todo → Doing → Done → Todo（循環）
/// progress: Todo=0, Doing=50, Done=100
class TaskStatus {
  final String value;

  TaskStatus._(this.value);

  /// ステータス：未着手
  factory TaskStatus.todo() => TaskStatus._('todo');

  /// ステータス：進行中
  factory TaskStatus.doing() => TaskStatus._('doing');

  /// ステータス：完了
  factory TaskStatus.done() => TaskStatus._('done');

  /// 次のステータスに遷移（循環：Todo → Doing → Done → Todo）
  TaskStatus nextStatus() {
    return switch (value) {
      'todo' => TaskStatus.doing(),
      'doing' => TaskStatus.done(),
      'done' => TaskStatus.todo(),
      _ => throw ArgumentError('Invalid status: $value'),
    };
  }

  /// 現在のステータスが Todo か
  bool get isTodo => value == 'todo';

  /// 現在のステータスが Doing か
  bool get isDoing => value == 'doing';

  /// 現在のステータスが Done か
  bool get isDone => value == 'done';

  /// 進捗率：Todo=0%, Doing=50%, Done=100%
  int get progress {
    return switch (value) {
      'todo' => 0,
      'doing' => 50,
      'done' => 100,
      _ => 0,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatus &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TaskStatus($value)';
}
