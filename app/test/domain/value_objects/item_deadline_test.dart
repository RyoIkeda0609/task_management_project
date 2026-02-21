import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

void main() {
  group('ItemDeadline ValueObject', () {
    group('initialization', () {
      test('ItemDeadline should accept valid DateTime', () {
        final deadline = DateTime(2025, 12, 31);
        final itemDeadline = ItemDeadline(deadline);
        expect(itemDeadline.value.year, 2025);
        expect(itemDeadline.value.month, 12);
        expect(itemDeadline.value.day, 31);
      });

      test('ItemDeadline should normalize time to 00:00:00', () {
        final deadline = DateTime(2025, 12, 31, 23, 59, 59);
        final itemDeadline = ItemDeadline(deadline);
        expect(itemDeadline.value.hour, 0);
        expect(itemDeadline.value.minute, 0);
        expect(itemDeadline.value.second, 0);
      });

      test('ItemDeadline with null should use today', () {
        final itemDeadline = ItemDeadline();
        final now = DateTime.now();
        expect(itemDeadline.value.year, now.year);
        expect(itemDeadline.value.month, now.month);
        expect(itemDeadline.value.day, now.day);
      });

      test('ItemDeadline should accept past dates', () {
        final pastDate = DateTime(2020, 1, 1);
        final itemDeadline = ItemDeadline(pastDate);
        expect(itemDeadline.value.year, 2020);
      });

      test('ItemDeadline should accept future dates', () {
        final futureDate = DateTime(2030, 12, 31);
        final itemDeadline = ItemDeadline(futureDate);
        expect(itemDeadline.value.year, 2030);
      });
    });

    group('comparison methods', () {
      test('isAfter should return true when deadline is after other', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1.isAfter(deadline2), true);
      });

      test('isAfter should return false when deadline is before other', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isAfter(deadline2), false);
      });

      test('isAfter should return false when deadlines are same', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isAfter(deadline2), false);
      });

      test('isBefore should return true when deadline is before other', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isBefore(deadline2), true);
      });

      test('isBefore should return false when deadline is after other', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1.isBefore(deadline2), false);
      });

      test('isBefore should return false when deadlines are same', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isBefore(deadline2), false);
      });

      test('isSame should return true when deadlines are same day', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31, 10, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31, 15, 45));
        expect(deadline1.isSame(deadline2), true);
      });

      test('isSame should return false when deadlines are different days', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1.isSame(deadline2), false);
      });
    });

    group('equality and hashCode', () {
      test('ItemDeadlines with the same day should be equal', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31, 10, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31, 15, 45));
        expect(deadline1, deadline2);
      });

      test('ItemDeadlines with different days should not be equal', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1, isNot(deadline2));
      });

      test('equal ItemDeadlines should have the same hashCode', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.hashCode, deadline2.hashCode);
      });

      test('should work correctly in Set', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline3 = ItemDeadline(DateTime(2025, 12, 30));

        final set = {deadline1, deadline2, deadline3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toString should return proper format', () {
        final deadline = ItemDeadline(DateTime(2025, 12, 31));
        final str = deadline.toString();
        expect(str, contains('ItemDeadline'));
        expect(str, contains('2025'));
        expect(str.contains('12') && str.contains('31'), true);
      });
    });
  });
}
