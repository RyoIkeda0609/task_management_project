import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_description.dart';

void main() {
  group('ItemDescription ValueObject', () {
    group('initialization', () {
      test('ItemDescription should accept non-empty string', () {
        const description = 'This is a description';
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });

      test('ItemDescription should accept empty string', () {
        const description = '';
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });

      test('ItemDescription should accept 500 character string', () {
        final description = 'a' * 500;
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });

      test(
        'ItemDescription should reject string longer than 500 characters',
        () {
          final description = 'a' * 501;
          expect(() => ItemDescription(description), throwsArgumentError);
        },
      );

      test('ItemDescription should accept whitespace-only string', () {
        const description = '   ';
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });

      test('ItemDescription should accept newlines and special characters', () {
        const description = 'Line 1\nLine 2\n\nLine 4\t with\ttabs';
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });
    });

    group('isNotEmpty helper', () {
      test('isNotEmpty should return true for non-empty description', () {
        final itemDesc = ItemDescription('Some description');
        expect(itemDesc.isNotEmpty, true);
      });

      test('isNotEmpty should return false for empty description', () {
        final itemDesc = ItemDescription('');
        expect(itemDesc.isNotEmpty, false);
      });

      test(
        'isNotEmpty should return false for whitespace-only description',
        () {
          final itemDesc = ItemDescription('   ');
          expect(itemDesc.isNotEmpty, false);
        },
      );

      test(
        'isNotEmpty should return true for description with content after whitespace',
        () {
          final itemDesc = ItemDescription('   content   ');
          expect(itemDesc.isNotEmpty, true);
        },
      );
    });

    group('equality and hashCode', () {
      test('ItemDescriptions with the same value should be equal', () {
        const descValue = 'Same description';
        final desc1 = ItemDescription(descValue);
        final desc2 = ItemDescription(descValue);

        expect(desc1, desc2);
      });

      test('ItemDescriptions with different values should not be equal', () {
        final desc1 = ItemDescription('Description 1');
        final desc2 = ItemDescription('Description 2');

        expect(desc1, isNot(desc2));
      });

      test('equal ItemDescriptions should have the same hashCode', () {
        const descValue = 'Same description';
        final desc1 = ItemDescription(descValue);
        final desc2 = ItemDescription(descValue);

        expect(desc1.hashCode, desc2.hashCode);
      });

      test('should work correctly in Set', () {
        final desc1 = ItemDescription('Description 1');
        final desc2 = ItemDescription('Description 1');
        final desc3 = ItemDescription('Description 2');

        final set = {desc1, desc2, desc3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toString should return proper format', () {
        final desc = ItemDescription('Test Description');
        expect(desc.toString(), contains('ItemDescription'));
        expect(desc.toString(), contains('Test Description'));
      });
    });

    group('maxLength constant', () {
      test('maxLength should be 500', () {
        expect(ItemDescription.maxLength, 500);
      });
    });
  });
}
