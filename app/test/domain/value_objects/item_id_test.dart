import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_id.dart';

void main() {
  group('ItemId ValueObject', () {
    group('initialization', () {
      test('ItemId should be initialized with a string value', () {
        const id = 'test-id-123';
        final itemId = ItemId(id);
        expect(itemId.value, id);
      });

      test('ItemId.generate() should create a new ItemId with UUID', () {
        final itemId1 = ItemId.generate();
        final itemId2 = ItemId.generate();

        expect(itemId1.value, isNotEmpty);
        expect(itemId2.value, isNotEmpty);
        expect(itemId1.value, isNot(itemId2.value));
      });

      test('generated ItemId should be valid UUID format', () {
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

    group('equality and hashCode', () {
      test('ItemIds with the same value should be equal', () {
        final itemId1 = ItemId('same-id');
        final itemId2 = ItemId('same-id');

        expect(itemId1, itemId2);
      });

      test('ItemIds with different values should not be equal', () {
        final itemId1 = ItemId('id-1');
        final itemId2 = ItemId('id-2');

        expect(itemId1, isNot(itemId2));
      });

      test('equal ItemIds should have the same hashCode', () {
        final itemId1 = ItemId('same-id');
        final itemId2 = ItemId('same-id');

        expect(itemId1.hashCode, itemId2.hashCode);
      });

      test('ItemId should work correctly in Set', () {
        final itemId1 = ItemId('id-1');
        final itemId2 = ItemId('id-1');
        final itemId3 = ItemId('id-2');

        final set = {itemId1, itemId2, itemId3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toString should return proper format', () {
        final itemId = ItemId('test-id');
        expect(itemId.toString(), contains('ItemId'));
        expect(itemId.toString(), contains('test-id'));
      });
    });
  });
}
