/// ItemTitle - アイテム名を表現する ValueObject
///
/// バリデーション：1～100文字、空白のみ不可
/// Goal、Milestone、Task で共通利用される
class ItemTitle {
  static const int maxLength = 100;
  final String value;

  ItemTitle(String val) : value = val {
    _validate();
  }

  void _validate() {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError(
        'ItemTitle must be between 1 and $maxLength characters (trimmed), got: "${value.length}"',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTitle &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ItemTitle($value)';
}
