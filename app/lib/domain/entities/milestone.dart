import '../entities/item.dart';
import '../value_objects/item/item_id.dart';
import '../value_objects/item/item_title.dart';
import '../value_objects/item/item_description.dart';
import '../value_objects/item/item_deadline.dart';

/// Milestone Entity - マイルストーン（中間目標）を表現する
///
/// 3 段階の階層構造の中間：Goal > Milestone > Task
/// Task の進捗を集約して Progress を自動計算する
/// Item を継承し、共通のバリデーション機構を利用する
class Milestone extends Item {
  final ItemId goalId;

  /// コンストラクタ
  Milestone({
    required ItemId itemId,
    required ItemTitle title,
    required ItemDescription description,
    required ItemDeadline deadline,
    required this.goalId,
  }) : super(
         itemId: itemId,
         title: title,
         description: description,
         deadline: deadline,
       );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Milestone &&
          runtimeType == other.runtimeType &&
          goalId == other.goalId;

  @override
  int get hashCode => super.hashCode ^ goalId.hashCode;

  @override
  String toString() => 'Milestone(itemId: $itemId, title: $title)';

  /// JSON に変換
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['goalId'] = goalId.value;
    return baseJson;
  }

  /// JSON から復元
  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    itemId: ItemId(json['itemId'] as String),
    title: ItemTitle(json['title'] as String),
    description: ItemDescription(json['description'] as String),
    deadline: ItemDeadline(DateTime.parse(json['deadline'] as String)),
    goalId: ItemId(json['goalId'] as String),
  );
}
