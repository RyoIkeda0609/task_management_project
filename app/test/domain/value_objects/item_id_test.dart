import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_id.dart';

void main() {
  group('ItemId', () {
    group('初期化', () {
      test('任意の文字列でItemIdが生成できること', () {
        const id = 'test-id-123';
        final itemId = ItemId(id);
        expect(itemId.value, id);
      });

      test('ItemId.generate()でUUID形式のItemIdが生成できること', () {
        final itemId1 = ItemId.generate();
        final itemId2 = ItemId.generate();
        expect(itemId1.value, isNotEmpty);
        expect(itemId2.value, isNotEmpty);
        expect(itemId1.value, isNot(itemId2.value));
      });

      test('生成されたItemIdはUUID v4形式であること', () {
        final itemId = ItemId.generate();
        // UUID v4 は 36文字のパターン（8-4-4-4-12）
        expect(
          itemId.value,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          ),
        );
      });
    });

    group('等価性とハッシュコード', () {
      test('同じ値のItemIdは等しいこと', () {
        final itemId1 = ItemId('same-id');
        final itemId2 = ItemId('same-id');
        expect(itemId1, itemId2);
      });

      test('異なる値のItemIdは等しくないこと', () {
        final itemId1 = ItemId('id-1');
        final itemId2 = ItemId('id-2');
        expect(itemId1, isNot(itemId2));
      });

      test('等しいItemIdは同じハッシュコードを持つこと', () {
        final itemId1 = ItemId('same-id');
        final itemId2 = ItemId('same-id');
        expect(itemId1.hashCode, itemId2.hashCode);
      });

      test('Setの中で正しく重複排除されること', () {
        final itemId1 = ItemId('id-1');
        final itemId2 = ItemId('id-1');
        final itemId3 = ItemId('id-2');
        final set = {itemId1, itemId2, itemId3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toStringがItemIdと値を含む文字列を返すこと', () {
        final itemId = ItemId('test-id');
        expect(itemId.toString(), contains('ItemId'));
        expect(itemId.toString(), contains('test-id'));
      });
    });
  });
}
