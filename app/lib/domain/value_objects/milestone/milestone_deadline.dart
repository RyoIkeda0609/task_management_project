/// MilestoneDeadline - マイルストーンの期限を表現する ValueObject
///
/// バリデーション：本日より後の日付のみ、時刻は00:00:00に正規化される
class MilestoneDeadline {
  final DateTime value;

  MilestoneDeadline(DateTime date) : value = _normalize(date) {
    _validate();
  }

  /// DateTime を年月日のみに正規化（時刻を00:00:00にする）
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _validate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!value.isAfter(today)) {
      throw ArgumentError(
        'MilestoneDeadline must be in the future, got: $value',
      );
    }
  }

  /// 他の期限より後かどうかを判定
  bool isAfter(MilestoneDeadline other) => value.isAfter(other.value);

  /// 他の期限より前かどうかを判定
  bool isBefore(MilestoneDeadline other) => value.isBefore(other.value);

  /// 他の期限と同じかどうかを判定
  bool isSame(MilestoneDeadline other) => value.isAtSameMomentAs(other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneDeadline &&
          runtimeType == other.runtimeType &&
          value.isAtSameMomentAs(other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'MilestoneDeadline(${value.year}-${value.month}-${value.day})';
}
