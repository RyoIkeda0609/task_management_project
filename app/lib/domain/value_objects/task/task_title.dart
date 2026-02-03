/// TaskTitle - タスク名を表現する ValueObject
///
/// バリデーション：1～100文字、空白のみ不可
class TaskTitle {
  static const int maxLength = 100;
  final String value;

  TaskTitle(this.value) {
    _validate();
  }

  void _validate() {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError(
        'TaskTitle must be between 1 and $maxLength characters (trimmed), got: "${value.length}"',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTitle &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TaskTitle($value)';
}
