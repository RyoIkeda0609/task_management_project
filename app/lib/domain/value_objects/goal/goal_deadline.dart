/// GoalDeadline - ゴールの期限を表現する ValueObject
///
/// バリデーション：任意の日付を許可（保存済みゴール復元時も対応）
/// 新規作成時は UseCase で本日以降にバリデーション
class GoalDeadline {
  late DateTime value;

  /// コンストラクタ
  GoalDeadline([DateTime? date]) {
    if (date == null) {
      // デフォルト値
      value = DateTime.now();
    } else {
      // 通常の使用（任意の日付を許可）
      value = _normalize(date);
    }
  }

  /// DateTime を年月日のみに正規化（時刻を00:00:00にする）
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 他の期限より後かどうかを判定
  bool isAfter(GoalDeadline other) => value.isAfter(other.value);

  /// 他の期限より前かどうかを判定
  bool isBefore(GoalDeadline other) => value.isBefore(other.value);

  /// 他の期限と同じかどうかを判定
  bool isSame(GoalDeadline other) => value.isAtSameMomentAs(other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalDeadline &&
          runtimeType == other.runtimeType &&
          value.isAtSameMomentAs(other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'GoalDeadline(${value.year}-${value.month}-${value.day})';
}
