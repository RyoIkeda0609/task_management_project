import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

/// Item - アイテムの基底エンティティ
///
/// Goal、Milestone、Task の親クラス
/// 共通のプロパティを集約し、バリデーションロジックを統一する
class Item {
  final ItemId itemId;
  final ItemTitle title;
  final ItemDescription description;
  final ItemDeadline deadline;

  /// コンストラクタ
  Item({
    required this.itemId,
    required this.title,
    required this.description,
    required this.deadline,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          title == other.title &&
          description == other.description &&
          deadline == other.deadline;

  @override
  int get hashCode =>
      itemId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      deadline.hashCode;

  @override
  String toString() => 'Item(itemId: $itemId, title: $title)';

  /// JSON に変換
  Map<String, dynamic> toJson() => {
    'itemId': itemId.value,
    'title': title.value,
    'description': description.value,
    'deadline': deadline.value.toIso8601String(),
  };

  /// JSON から復元
  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemId: ItemId(json['itemId'] as String),
    title: ItemTitle(json['title'] as String),
    description: ItemDescription(json['description'] as String),
    deadline: ItemDeadline(DateTime.parse(json['deadline'] as String)),
  );
}
