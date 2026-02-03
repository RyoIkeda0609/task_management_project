import 'package:uuid/uuid.dart';

/// GoalId - ゴール ID を表現する ValueObject
///
/// UUID 形式の一意識別子
class GoalId {
  late String value;

  GoalId([String? val]) {
    if (val == null) {
      value = '';
    } else {
      value = val;
    }
  }

  /// 新しい ID を自動生成
  factory GoalId.generate() => GoalId(const Uuid().v4());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GoalId($value)';
}
