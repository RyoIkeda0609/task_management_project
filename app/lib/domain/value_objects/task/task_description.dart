/// TaskDescription - タスクの説明を表現する ValueObject
///
/// バリデーション：1～500文字、空白のみ不可
class TaskDescription {
  static const int maxLength = 500;
  final String value;

  TaskDescription(this.value) {
    _validate();
  }

  void _validate() {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError(
        'TaskDescription must be between 1 and $maxLength characters (trimmed), got: "${value.length}"',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDescription &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TaskDescription($value)';
}
