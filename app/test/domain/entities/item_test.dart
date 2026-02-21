import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/item.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

void main() {
  group('Item Parent Entity', () {
    late Item item;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      item = Item(
        itemId: ItemId('item-1'),
        title: ItemTitle('Test Item'),
        description: ItemDescription('This is a test item'),
        deadline: ItemDeadline(tomorrow),
      );
    });

    group('initialization', () {
      test('Item should be initialized with required fields', () {
        expect(item.itemId.value, 'item-1');
        expect(item.title.value, 'Test Item');
        expect(item.description.value, 'This is a test item');
        expect(item.deadline.value.day, tomorrow.day);
      });

      test('Item should accept empty description', () {
        final itemEmptyDesc = Item(
          itemId: ItemId('item-2'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
        );
        expect(itemEmptyDesc.description.value, '');
      });

      test('Item can be created with generated ID', () {
        final itemWithGeneratedId = Item(
          itemId: ItemId.generate(),
          title: ItemTitle('Test'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(itemWithGeneratedId.itemId.value.isNotEmpty, true);
      });
    });

    group('equality and hashCode', () {
      test('Items with the same field values should be equal', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('Test Item'),
          description: ItemDescription('This is a test item'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, item2);
      });

      test('Items with different itemId should not be equal', () {
        final item2 = Item(
          itemId: ItemId('item-2'),
          title: ItemTitle('Test Item'),
          description: ItemDescription('This is a test item'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, isNot(item2));
      });

      test('Items with different title should not be equal', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('Different Title'),
          description: ItemDescription('This is a test item'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, isNot(item2));
      });

      test('Items with different description should not be equal', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('Test Item'),
          description: ItemDescription('Different description'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item, isNot(item2));
      });

      test('equal Items should have the same hashCode', () {
        final item2 = Item(
          itemId: ItemId('item-1'),
          title: ItemTitle('Test Item'),
          description: ItemDescription('This is a test item'),
          deadline: ItemDeadline(tomorrow),
        );
        expect(item.hashCode, item2.hashCode);
      });
    });

    group('toString', () {
      test('toString should return proper format', () {
        final str = item.toString();
        expect(str, contains('Item'));
        expect(str, contains('item-1'));
        expect(str, contains('Test Item'));
      });
    });

    group('JSON serialization', () {
      test('toJson should convert Item to JSON', () {
        final json = item.toJson();
        expect(json['itemId'], 'item-1');
        expect(json['title'], 'Test Item');
        expect(json['description'], 'This is a test item');
        expect(json['deadline'], isNotNull);
      });

      test('fromJson should restore Item from JSON', () {
        final json = item.toJson();
        final restored = Item.fromJson(json);
        expect(restored, item);
      });

      test('fromJson should restore all fields correctly', () {
        final json = {
          'itemId': 'item-123',
          'title': 'Sample Item',
          'description': 'Sample description',
          'deadline': tomorrow.toIso8601String(),
        };
        final restored = Item.fromJson(json);
        expect(restored.itemId.value, 'item-123');
        expect(restored.title.value, 'Sample Item');
        expect(restored.description.value, 'Sample description');
      });
    });
  });
}
