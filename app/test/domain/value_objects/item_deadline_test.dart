import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

void main() {
  group('ItemDeadline', () {
    group('初期化', () {
      test('有効なDateTimeでItemDeadlineが生成できること', () {
        final deadline = DateTime(2025, 12, 31);
        final itemDeadline = ItemDeadline(deadline);
        expect(itemDeadline.value.year, 2025);
        expect(itemDeadline.value.month, 12);
        expect(itemDeadline.value.day, 31);
      });

      test('時刻は00:00:00に正規化されること', () {
        final deadline = DateTime(2025, 12, 31, 23, 59, 59);
        final itemDeadline = ItemDeadline(deadline);
        expect(itemDeadline.value.hour, 0);
        expect(itemDeadline.value.minute, 0);
        expect(itemDeadline.value.second, 0);
      });

      test('引数なしで生成すると本日の日付になること', () {
        final itemDeadline = ItemDeadline();
        final now = DateTime.now();
        expect(itemDeadline.value.year, now.year);
        expect(itemDeadline.value.month, now.month);
        expect(itemDeadline.value.day, now.day);
      });

      test('過去の日付も有効であること', () {
        final pastDate = DateTime(2020, 1, 1);
        final itemDeadline = ItemDeadline(pastDate);
        expect(itemDeadline.value.year, 2020);
      });

      test('未来の日付も有効であること', () {
        final futureDate = DateTime(2030, 12, 31);
        final itemDeadline = ItemDeadline(futureDate);
        expect(itemDeadline.value.year, 2030);
      });
    });

    group('比較メソッド', () {
      test('isAfter: 期日が他より後ならtrueを返すこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1.isAfter(deadline2), true);
      });

      test('isAfter: 期日が他より前ならfalseを返すこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isAfter(deadline2), false);
      });

      test('isAfter: 期日が同じならfalseを返すこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isAfter(deadline2), false);
      });

      test('isBefore: 期日が他より前ならtrueを返すこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isBefore(deadline2), true);
      });

      test('isBefore: 期日が他より後ならfalseを返すこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1.isBefore(deadline2), false);
      });

      test('isBefore: 期日が同じならfalseを返すこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.isBefore(deadline2), false);
      });

      test('isSame: 同じ日ならtrueを返すこと（時刻は関係ない）', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31, 10, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31, 15, 45));
        expect(deadline1.isSame(deadline2), true);
      });

      test('isSame: 異なる日ならfalseを返すこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1.isSame(deadline2), false);
      });
    });

    group('等価性とハッシュコード', () {
      test('同じ日のItemDeadlineは等しいこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31, 10, 30));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31, 15, 45));
        expect(deadline1, deadline2);
      });

      test('異なる日のItemDeadlineは等しくないこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 30));
        expect(deadline1, isNot(deadline2));
      });

      test('等しいItemDeadlineは同じハッシュコードを持つこと', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        expect(deadline1.hashCode, deadline2.hashCode);
      });

      test('Setの中で正しく重複排除されること', () {
        final deadline1 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline2 = ItemDeadline(DateTime(2025, 12, 31));
        final deadline3 = ItemDeadline(DateTime(2025, 12, 30));
        final set = {deadline1, deadline2, deadline3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toStringがItemDeadlineと日付を含む文字列を返すこと', () {
        final deadline = ItemDeadline(DateTime(2025, 12, 31));
        final str = deadline.toString();
        expect(str, contains('ItemDeadline'));
        expect(str, contains('2025'));
        expect(str.contains('12') && str.contains('31'), true);
      });
    });
  });
}
