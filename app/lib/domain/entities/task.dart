import '../entities/item.dart';
import '../value_objects/item/item_id.dart';
import '../value_objects/item/item_title.dart';
import '../value_objects/item/item_description.dart';
import '../value_objects/item/item_deadline.dart';
import '../value_objects/task/task_status.dart';
import '../value_objects/shared/progress.dart';

/// Task Entity - タスク（具体的な作業）を表現する
///
/// 3 段階の階層構造の最下位：Goal > Milestone > Task
/// ステータス（Todo/Doing/Done）により Progress が決定される
/// Item を継承し、共通のバリデーション機構を利用する
class Task extends Item {
  final TaskStatus status;
  final ItemId milestoneId;

  /// コンストラクタ
  Task({
    required super.itemId,
    required super.title,
    required super.description,
    required super.deadline,
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
      itemId: itemId,
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
      super == other &&
          other is Task &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          milestoneId == other.milestoneId;

  @override
  int get hashCode => super.hashCode ^ status.hashCode ^ milestoneId.hashCode;

  @override
  String toString() =>
      'Task(itemId: $itemId, title: $title, status: ${status.value})';

  /// JSON に変換
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['status'] = status.value;
    baseJson['milestoneId'] = milestoneId.value;
    return baseJson;
  }

  /// JSON から復元
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    itemId: ItemId(json['itemId'] as String),
    title: ItemTitle(json['title'] as String),
    description: ItemDescription(json['description'] as String),
    deadline: ItemDeadline(DateTime.parse(json['deadline'] as String)),
    status: TaskStatus(json['status'] as String),
    milestoneId: ItemId(json['milestoneId'] as String),
  );
}
