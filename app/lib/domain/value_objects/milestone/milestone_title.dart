/// MilestoneTitle - マイルストーン名を表現する ValueObject
///
/// バリデーション：1～100文字、空白のみ不可
class MilestoneTitle {
  static const int maxLength = 100;
  late String value;

  MilestoneTitle(String val) {
    value = val;
    _validate();
  }

  void _validate() {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError(
        'MilestoneTitle must be between 1 and $maxLength characters (trimmed), got: "${value.length}"',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneTitle &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MilestoneTitle($value)';
}
