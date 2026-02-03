/// Progress - 進捗率を表現する ValueObject
///
/// 値の範囲：0～100
class Progress {
  final int value;

  Progress(this.value) {
    _validate();
  }

  void _validate() {
    if (value < 0 || value > 100) {
      throw ArgumentError('Progress must be between 0 and 100, got: $value');
    }
  }

  /// 完了状態（progress == 100）か
  bool get isCompleted => value == 100;

  /// 未開始状態（progress == 0）か
  bool get isNotStarted => value == 0;

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
