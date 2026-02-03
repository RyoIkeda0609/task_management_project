import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'milestone_id.g.dart';

/// MilestoneId - マイルストーンの ID を表現する ValueObject
///
/// UUID v4 による一意の識別子
@HiveType(typeId: 20)
class MilestoneId {
  @HiveField(0)
  late String value;

  MilestoneId([String? val]) {
    if (val == null) {
      value = '';
    } else {
      value = val;
    }
  }

  /// 新しい MilestoneId を自動生成する
  factory MilestoneId.generate() => MilestoneId(const Uuid().v4());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MilestoneId($value)';
}
