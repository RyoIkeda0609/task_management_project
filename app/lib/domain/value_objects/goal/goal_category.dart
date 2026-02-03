/// GoalCategory - ゴールのカテゴリを表現する ValueObject
///
/// バリデーション：1～100文字、空白のみ不可
import 'package:hive/hive.dart';

part 'goal_category.g.dart';

@HiveType(typeId: 12)
class GoalCategory {
  static const int maxLength = 100;
  @HiveField(0)
  late String value;

  GoalCategory([String? val]) {
    if (val == null) {
      value = '';
    } else {
      value = val;
      _validate();
    }
  }

  void _validate() {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError(
        'GoalCategory must be between 1 and $maxLength characters (trimmed), got: "${value.length}"',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalCategory &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GoalCategory($value)';
}
