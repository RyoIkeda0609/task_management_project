/// ItemDeadline - アイテムの期限を表現する ValueObject
///
/// バリデーション：任意の日付を許可（保存済みアイテム復元時も対応）
/// 新規作成時は UseCase で本日以降にバリデーション
/// Goal、Milestone、Task で共通利用される
class ItemDeadline {
  final DateTime value;

  /// コンストラクタ
  ItemDeadline([DateTime? date])
    : value = date != null ? _normalize(date) : _normalize(DateTime.now());

  /// DateTime を年月日のみに正規化（時刻を00:00:00にする）
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 他の期限より後かどうかを判定
  bool isAfter(ItemDeadline other) => value.isAfter(other.value);

  /// 他の期限より前かどうかを判定
  bool isBefore(ItemDeadline other) => value.isBefore(other.value);

  /// 他の期限と同じかどうかを判定
  bool isSame(ItemDeadline other) => value.isAtSameMomentAs(other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemDeadline &&
          runtimeType == other.runtimeType &&
          value.isAtSameMomentAs(other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'ItemDeadline(${value.year}-${value.month}-${value.day})';
}
