import '../value_objects/goal/goal_id.dart';
import '../value_objects/goal/goal_title.dart';
import '../value_objects/goal/goal_category.dart';
import '../value_objects/goal/goal_reason.dart';
import '../value_objects/goal/goal_deadline.dart';
import '../value_objects/shared/progress.dart';

/// Goal Entity - ゴール（目標）を表現する
///
/// 3 段階の階層構造の最上位：Goal > Milestone > Task
class Goal {
  final GoalId id;
  final GoalTitle title;
  final GoalCategory category;
  final GoalReason reason;
  final GoalDeadline deadline;
  // progressはマイルストーンから自動計算される
  // milestones: List<Milestone> は別途リポジトリで管理

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.reason,
    required this.deadline,
  });

  /// Progress を計算する（マイルストーンの進捗から自動算出）
  ///
  /// マイルストーンが存在しない場合は Progress(0) を返す
  Progress calculateProgress(List<Progress> milestoneProgresses) {
    if (milestoneProgresses.isEmpty) {
      return Progress(0);
    }
    final average =
        milestoneProgresses.fold<int>(0, (sum, p) => sum + p.value) ~/
        milestoneProgresses.length;
    return Progress(average);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          reason == other.reason &&
          deadline == other.deadline;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      category.hashCode ^
      reason.hashCode ^
      deadline.hashCode;

  @override
  String toString() => 'Goal(id: $id, title: $title)';
}
