import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_title.dart';

void main() {
  group('ItemTitle ValueObject', () {
    group('initialization', () {
      test('ItemTitle should accept valid title', () {
        const title = 'Valid Task Title';
        final itemTitle = ItemTitle(title);
        expect(itemTitle.value, title);
      });

      test('ItemTitle should trim whitespace', () {
        const title = '  Valid Task Title  ';
        final itemTitle = ItemTitle(title);
        expect(itemTitle.value, title);
        expect(itemTitle.value.trim().length, 'Valid Task Title'.length);
      });

      test('ItemTitle should accept 100 character string', () {
        final title = 'a' * 100;
        final itemTitle = ItemTitle(title);
        expect(itemTitle.value, title);
      });

      test('ItemTitle should reject empty string', () {
        expect(() => ItemTitle(''), throwsArgumentError);
      });

      test('ItemTitle should reject whitespace-only string', () {
        expect(() => ItemTitle('   '), throwsArgumentError);
      });

      test('ItemTitle should reject string longer than 100 characters', () {
        final title = 'a' * 101;
        expect(() => ItemTitle(title), throwsArgumentError);
      });

      test('ItemTitle should accept string with exactly 100 characters', () {
        final title = 'a' * 100;
        final itemTitle = ItemTitle(title);
        expect(itemTitle.value.length, 100);
      });
    });

    group('equality and hashCode', () {
      test('ItemTitles with the same value should be equal', () {
        const titleValue = 'Same Title';
        final title1 = ItemTitle(titleValue);
        final title2 = ItemTitle(titleValue);

        expect(title1, title2);
      });

      test('ItemTitles with different values should not be equal', () {
        final title1 = ItemTitle('Title 1');
        final title2 = ItemTitle('Title 2');

        expect(title1, isNot(title2));
      });

      test('equal ItemTitles should have the same hashCode', () {
        const titleValue = 'Same Title';
        final title1 = ItemTitle(titleValue);
        final title2 = ItemTitle(titleValue);

        expect(title1.hashCode, title2.hashCode);
      });

      test('should work correctly in Set', () {
        final title1 = ItemTitle('Title 1');
        final title2 = ItemTitle('Title 1');
        final title3 = ItemTitle('Title 2');

        final set = {title1, title2, title3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toString should return proper format', () {
        final title = ItemTitle('Test Title');
        expect(title.toString(), contains('ItemTitle'));
        expect(title.toString(), contains('Test Title'));
      });
    });

    group('maxLength constant', () {
      test('maxLength should be 100', () {
        expect(ItemTitle.maxLength, 100);
      });
    });
  });
}
