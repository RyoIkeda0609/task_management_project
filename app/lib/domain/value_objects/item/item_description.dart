/// ItemDescription - アイテムの説明を表現する ValueObject
///
/// バリデーション：0～500文字
/// 任意フィールド。空文字列も許容。
/// Goal、Milestone、Task で共通利用される
class ItemDescription {
  static const int maxLength = 500;
  final String value;

  ItemDescription(String val) : value = val {
    _validate();
  }

  void _validate() {
    if (value.length > maxLength) {
      throw ArgumentError(
        'ItemDescription must not exceed $maxLength characters (got: "${value.length}")',
      );
    }
  }

  /// 説明が入力されているかチェック
  bool get isNotEmpty => value.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemDescription &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ItemDescription($value)';
}
