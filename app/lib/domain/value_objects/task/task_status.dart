/// TaskStatus - タスクのステータスを表現する ValueObject
///
/// 状態遷移：Todo → Doing → Done → Todo（循環）
/// progress: Todo=0, Doing=50, Done=100
class TaskStatus {
  /// ステータス値
  static const String statusTodo = 'todo';
  static const String statusDoing = 'doing';
  static const String statusDone = 'done';

  /// 進捗率値
  static const int progressTodo = 0;
  static const int progressDoing = 50;
  static const int progressDone = 100;

  late String value;

  /// コンストラクタ（明示的なステータス値が必須）
  TaskStatus(String val) {
    value = val;
  }

  /// ステータス：未着手
  factory TaskStatus.todo() => TaskStatus(statusTodo);

  /// ステータス：進行中
  factory TaskStatus.doing() => TaskStatus(statusDoing);

  /// ステータス：完了
  factory TaskStatus.done() => TaskStatus(statusDone);

  /// 次のステータスに遷移（循環：Todo → Doing → Done → Todo）
  TaskStatus nextStatus() {
    return switch (value) {
      statusTodo => TaskStatus.doing(),
      statusDoing => TaskStatus.done(),
      statusDone => TaskStatus.todo(),
      _ => throw ArgumentError('Invalid status: $value'),
    };
  }

  /// 現在のステータスが Todo か
  bool get isTodo => value == statusTodo;

  /// 現在のステータスが Doing か
  bool get isDoing => value == statusDoing;

  /// 現在のステータスが Done か
  bool get isDone => value == statusDone;

  /// 進捗率：Todo=0%, Doing=50%, Done=100%
  int get progress {
    return switch (value) {
      statusTodo => progressTodo,
      statusDoing => progressDoing,
      statusDone => progressDone,
      _ => progressTodo,
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
