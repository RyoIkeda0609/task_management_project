/// TaskStatus - タスクのステータスを表現する列挙型 ValueObject
///
/// 状態遷移：Todo → Doing → Done → Todo（循環）
/// progress: Todo=0, Doing=50, Done=100
///
/// enum により将来のステータス追加（例: archived）時に
/// switch 文の網羅性がコンパイル時に保証される。
enum TaskStatus {
  /// ステータス：未着手
  todo,

  /// ステータス：進行中
  doing,

  /// ステータス：完了
  done;

  /// シリアライズ用の文字列値（JSON/Hive 永続化互換）
  String get value => name;

  /// 進捗率定数
  static const int progressTodo = 0;
  static const int progressDoing = 50;
  static const int progressDone = 100;

  /// 文字列からの復元（デシリアライズ用）
  ///
  /// 不正な値は [ArgumentError] をスローする。
  /// フォールバックは行わず、データ破損を即座に検出する。
  static TaskStatus fromString(String value) {
    return switch (value) {
      'todo' => TaskStatus.todo,
      'doing' => TaskStatus.doing,
      'done' => TaskStatus.done,
      _ => throw ArgumentError('不正なステータス値です: $value'),
    };
  }

  /// 次のステータスに遷移（循環：Todo → Doing → Done → Todo）
  TaskStatus nextStatus() {
    return switch (this) {
      TaskStatus.todo => TaskStatus.doing,
      TaskStatus.doing => TaskStatus.done,
      TaskStatus.done => TaskStatus.todo,
    };
  }

  /// 現在のステータスが Todo か
  bool get isTodo => this == TaskStatus.todo;

  /// 現在のステータスが Doing か
  bool get isDoing => this == TaskStatus.doing;

  /// 現在のステータスが Done か
  bool get isDone => this == TaskStatus.done;

  /// 進捗率：Todo=0%, Doing=50%, Done=100%
  int get progress {
    return switch (this) {
      TaskStatus.todo => progressTodo,
      TaskStatus.doing => progressDoing,
      TaskStatus.done => progressDone,
    };
  }
}
