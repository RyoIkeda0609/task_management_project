import '../value_objects/milestone/milestone_id.dart';
import '../value_objects/milestone/milestone_title.dart';
import '../value_objects/milestone/milestone_deadline.dart';

/// Milestone Entity - マイルストーン（中間目標）を表現する
///
/// 3 段階の階層構造の中間：Goal > Milestone > Task
/// Task の進捗を集約して Progress を自動計算する
class Milestone {
  final MilestoneId id;
  final MilestoneTitle title;
  final MilestoneDeadline deadline;
  final String goalId;
  // tasks: List<Task> は別途リポジトリで管理

  Milestone({
    required this.id,
    required this.title,
    required this.deadline,
    required this.goalId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Milestone &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          deadline == other.deadline &&
          goalId == other.goalId;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ deadline.hashCode ^ goalId.hashCode;

  @override
  String toString() => 'Milestone(id: $id, title: $title)';

  /// JSON に変換
  Map<String, dynamic> toJson() => {
    'id': id.value,
    'title': title.value,
    'deadline': deadline.value.toIso8601String(),
    'goalId': goalId,
  };

  /// JSON から復元
  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: MilestoneId(json['id'] as String),
    title: MilestoneTitle(json['title'] as String),
    deadline: MilestoneDeadline(DateTime.parse(json['deadline'] as String)),
    goalId: json['goalId'] as String,
  );
}
