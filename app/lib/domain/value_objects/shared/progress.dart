/// Progress - 進捗率を表現する ValueObject
///
/// 値の範囲：0～100
class Progress {
  static const int minValue = 0;
  static const int maxValue = 100;

  late int value;

  Progress([int? val]) {
    if (val == null) {
      value = minValue;
    } else {
      value = val;
      _validate();
    }
  }

  void _validate() {
    if (value < minValue || value > maxValue) {
      throw ArgumentError(
        'Progress must be between $minValue and $maxValue, got: $value',
      );
    }
  }

  /// 完了状態（progress == 100）か
  bool get isCompleted => value == maxValue;

  /// 未開始状態（progress == 0）か
  bool get isNotStarted => value == minValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Progress &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Progress($value%)';
}
