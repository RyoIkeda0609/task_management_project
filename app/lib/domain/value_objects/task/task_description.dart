/// TaskDescription - タスクの説明を表現する ValueObject
///
/// バリデーション：
/// - 空文字列は不可
/// - nullの場合は空文字列に変換（任意フィールド）
/// - 値がある場合は1～500文字、空白のみ不可
class TaskDescription {
  static const int maxLength = 500;
  late String value;

  TaskDescription([String? val]) {
    if (val == null) {
      value = '';
    } else {
      value = val;
      _validate();
    }
  }

  void _validate() {
    if (value.isEmpty) {
      throw ArgumentError('TaskDescription cannot be empty');
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError(
        'TaskDescription must be between 1 and $maxLength characters (trimmed), got: "${value.length}"',
      );
    }
  }

  /// 説明が入力されているかチェック
  bool get isNotEmpty => value.trim().isNotEmpty;

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
