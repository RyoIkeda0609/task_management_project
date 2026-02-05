import '../value_objects/task/task_id.dart';
import '../value_objects/task/task_title.dart';
import '../value_objects/task/task_description.dart';
import '../value_objects/task/task_deadline.dart';
import '../value_objects/task/task_status.dart';
import '../value_objects/shared/progress.dart';

/// Task Entity - タスク（具体的な作業）を表現する
///
/// 3 段階の階層構造の最下位：Goal > Milestone > Task
/// ステータス（Todo/Doing/Done）により Progress が決定される
class Task {
  final TaskId id;
  final TaskTitle title;
  final TaskDescription description;
  final TaskDeadline deadline;
  final TaskStatus status;
  final String milestoneId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.milestoneId,
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
      milestoneId: milestoneId,
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
          status == other.status &&
          milestoneId == other.milestoneId;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      deadline.hashCode ^
      status.hashCode ^
      milestoneId.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title, status: ${status.value})';

  /// JSON に変換
  Map<String, dynamic> toJson() => {
    'id': id.value,
    'title': title.value,
    'description': description.value,
    'deadline': deadline.value.toIso8601String(),
    'status': status.value,
    'milestoneId': milestoneId,
  };

  /// JSON から復元
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: TaskId(json['id'] as String),
    title: TaskTitle(json['title'] as String),
    description: TaskDescription(json['description'] as String),
    deadline: TaskDeadline(DateTime.parse(json['deadline'] as String)),
    status: TaskStatus(json['status'] as String),
    milestoneId: json['milestoneId'] as String,
  );
}
