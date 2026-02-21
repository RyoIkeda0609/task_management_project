import 'package:uuid/uuid.dart';

/// ItemId - アイテム ID を表現する ValueObject
///
/// UUID 形式の一意識別子
/// Goal、Milestone、Task で共通利用される
class ItemId {
  final String value;

  ItemId(this.value);

  /// 新しい ID を自動生成
  factory ItemId.generate() => ItemId(const Uuid().v4());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ItemId($value)';
}
