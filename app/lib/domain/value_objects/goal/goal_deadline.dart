/// GoalDeadline - ゴールの期限を表現する ValueObject
///
/// バリデーション：本日より後の日付のみ、時刻は00:00:00に正規化される
import 'package:hive/hive.dart';

part 'goal_deadline.g.dart';

@HiveType(typeId: 14)
class GoalDeadline {
  @HiveField(0)
  late DateTime value;

  /// コンストラクタ（Hive用デフォルト値対応）
  GoalDeadline([DateTime? date]) {
    if (date == null) {
      // Hive deserialize 時
      value = DateTime.now();
    } else {
      // 通常の使用
      value = _normalize(date);
      _validate();
    }
  }

  /// DateTime を年月日のみに正規化（時刻を00:00:00にする）
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _validate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!value.isAfter(today)) {
      throw ArgumentError('GoalDeadline must be in the future, got: $value');
    }
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
