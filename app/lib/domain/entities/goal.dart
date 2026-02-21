import '../entities/item.dart';
import '../value_objects/item/item_id.dart';
import '../value_objects/item/item_title.dart';
import '../value_objects/item/item_description.dart';
import '../value_objects/item/item_deadline.dart';
import '../value_objects/goal/goal_category.dart';

/// Goal Entity - ゴール（目標）を表現する
///
/// 3 段階の階層構造の最上位：Goal > Milestone > Task
/// Item を継承し、共通のバリデーション機構を利用する
class Goal extends Item {
  final GoalCategory category;

  /// コンストラクタ
  Goal({
    required ItemId itemId,
    required ItemTitle title,
    required ItemDescription description,
    required ItemDeadline deadline,
    required this.category,
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
          other is Goal &&
          runtimeType == other.runtimeType &&
          category == other.category;

  @override
  int get hashCode => super.hashCode ^ category.hashCode;

  @override
  String toString() => 'Goal(itemId: $itemId, title: $title)';

  /// JSON に変換
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['category'] = category.value;
    return baseJson;
  }

  /// JSON から復元
  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    itemId: ItemId(json['itemId'] as String),
    title: ItemTitle(json['title'] as String),
    description: ItemDescription(json['description'] as String),
    deadline: ItemDeadline(DateTime.parse(json['deadline'] as String)),
    category: GoalCategory(json['category'] as String),
  );
}
