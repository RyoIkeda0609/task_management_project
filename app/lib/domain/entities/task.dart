import 'package:hive/hive.dart';
import '../value_objects/task/task_id.dart';
import '../value_objects/task/task_title.dart';
import '../value_objects/task/task_description.dart';
import '../value_objects/task/task_deadline.dart';
import '../value_objects/task/task_status.dart';
import '../value_objects/shared/progress.dart';

part 'task.g.dart';

/// Task Entity - タスク（具体的な作業）を表現する
///
/// 3 段階の階層構造の最下位：Goal > Milestone > Task
/// ステータス（Todo/Doing/Done）により Progress が決定される
@HiveType(typeId: 2)
class Task {
  @HiveField(0)
  final TaskId id;
  @HiveField(1)
  final TaskTitle title;
  @HiveField(2)
  final TaskDescription description;
  @HiveField(3)
  final TaskDeadline deadline;
  @HiveField(4)
  final TaskStatus status;
  // milestoneId: Milestone との関連付けのため（リポジトリで管理）

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
  });

  /// タスクの Progress を取得する
  ///
  /// ステータスにより自動決定される：
  /// - Todo: 0%
  /// - Doing: 50%
  /// - Done: 100%
  Progress getProgress() => Progress(status.progress);

  /// ステータスを次の状態に遷移させる
  ///
  /// Todo → Doing → Done → Todo（循環）
  Task cycleStatus() {
    return Task(
      id: id,
      title: title,
      description: description,
      deadline: deadline,
      status: status.nextStatus(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          deadline == other.deadline &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      deadline.hashCode ^
      status.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title, status: ${status.value})';
}
