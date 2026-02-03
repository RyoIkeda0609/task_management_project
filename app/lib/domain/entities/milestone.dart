import 'package:hive/hive.dart';
import '../value_objects/milestone/milestone_id.dart';
import '../value_objects/milestone/milestone_title.dart';
import '../value_objects/milestone/milestone_deadline.dart';
import '../value_objects/shared/progress.dart';

part 'milestone.g.dart';

/// Milestone Entity - マイルストーン（中間目標）を表現する
///
/// 3 段階の階層構造の中間：Goal > Milestone > Task
/// Task の進捗を集約して Progress を自動計算する
@HiveType(typeId: 1)
class Milestone {
  @HiveField(0)
  final MilestoneId id;
  @HiveField(1)
  final MilestoneTitle title;
  @HiveField(2)
  final MilestoneDeadline deadline;
  // goalId: Goal との関連付けのため（リポジトリで管理）
  // tasks: List<Task> は別途リポジトリで管理

  Milestone({required this.id, required this.title, required this.deadline});

  /// Progress を計算する（タスクの進捗から自動算出）
  ///
  /// タスクが存在しない場合は Progress(0) を返す
  Progress calculateProgress(List<Progress> taskProgresses) {
    if (taskProgresses.isEmpty) {
      return Progress(0);
    }
    final average =
        taskProgresses.fold<int>(0, (sum, p) => sum + p.value) ~/
        taskProgresses.length;
    return Progress(average);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Milestone &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          deadline == other.deadline;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ deadline.hashCode;

  @override
  String toString() => 'Milestone(id: $id, title: $title)';
}
