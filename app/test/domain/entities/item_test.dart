import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/item.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

void main() {
  group('Item 親エンティティ', () {
    late Item item;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      item = Item(
        itemId: ItemId('item-1'),
        title: ItemTitle('テストアイテム'),
        description: ItemDescription('これはテスト用のアイテムです'),
        deadline: ItemDeadline(tomorrow),
      );
    });

    group('初期化', () {
      test('全フィールドが正しく設定されること', () {
        expect(item.itemId.value, 'item-1');
        expect(item.title.value, 'テストアイテム');
        expect(item.description.value, 'これはテスト用のアイテムです');
        expect(item.deadline.value.day, tomorrow.day);
      });

      test('空の説明文でItemが生成できること', () {
        final itemEmptyDesc = Item(
          itemId: ItemId('item-2'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
        );
        expect(itemEmptyDesc.description.value, '');
      });

      test('ItemId.generate()でItemが生成できること', () {
        final itemWithGeneratedId = Item(
          itemId: ItemId.generate(),
          title: ItemTitle('Test'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(itemWithGeneratedId.itemId.value.isNotEmpty, true);
      });
    });

    group('等価性とハッシュコード', () {
      test('同じフィールドを持つItemは等しいこと', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('テストアイテム'),
          description: ItemDescription('これはテスト用のアイテムです'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, item2);
      });

      test('異なるitemIdを持つItemは等しくないこと', () {
        final item2 = Item(
          itemId: ItemId('item-2'),
          title: ItemTitle('テストアイテム'),
          description: ItemDescription('これはテスト用のアイテムです'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, isNot(item2));
      });

      test('異なるタイトルを持つItemは等しくないこと', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('別のタイトル'),
          description: ItemDescription('これはテスト用のアイテムです'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, isNot(item2));
      });

      test('異なる説明文を持つItemは等しくないこと', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('テストアイテム'),
          description: ItemDescription('別の説明文'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, isNot(item2));
      });

      test('等しいItemは同じハッシュコードを持つこと', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('テストアイテム'),
          description: ItemDescription('これはテスト用のアイテムです'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item.hashCode, item2.hashCode);
      });
    });

    group('toString', () {
      test('toStringがItemとitemIdとtitleを含む文字列を返すこと', () {
        final str = item.toString();
        expect(str, contains('Item'));
        expect(str, contains('item-1'));
        expect(str, contains('テストアイテム'));
      });
    });

    group('JSONシリアライズ', () {
      test('toJsonで全フィールドが含まれること', () {
        final json = item.toJson();
        expect(json['itemId'], 'item-1');
        expect(json['title'], 'テストアイテム');
        expect(json['description'], 'これはテスト用のアイテムです');
        expect(json['deadline'], isNotNull);
      });

      test('fromJsonでItemが正しく復元できること', () {
        final json = item.toJson();
        final restored = Item.fromJson(json);
        expect(restored, item);
      });

      test('fromJsonで全フィールドが正しく復元できること', () {
        final json = {
          'itemId': 'item-123',
          'title': 'サンプルアイテム',
          'description': 'サンプル説明文',
          'deadline': tomorrow.toIso8601String(),
        };
        final restored = Item.fromJson(json);
        expect(restored.itemId.value, 'item-123');
        expect(restored.title.value, 'サンプルアイテム');
        expect(restored.description.value, 'サンプル説明文');
      });
    });
  });
}
