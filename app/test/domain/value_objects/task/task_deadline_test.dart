import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';

void main() {
  group('TaskDeadline', () {
    group('コンストラクタ', () {
      test('本日より後の日付で TaskDeadline が生成できること', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final deadline = TaskDeadline(tomorrow);
        expect(deadline.value.year, tomorrow.year);
        expect(deadline.value.month, tomorrow.month);
        expect(deadline.value.day, tomorrow.day);
      });

      test('本日以前の日付でもコンストラクタが動作すること（システム日付が進むため）', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(() => TaskDeadline(yesterday), returnsNormally);
      });
    });

    group('等価性', () {
      test('同じ日付の TaskDeadline は等しいこと', () {
        final date = DateTime(2030, 12, 31);
        final deadline1 = TaskDeadline(date);
        final deadline2 = TaskDeadline(date);
        expect(deadline1, equals(deadline2));
      });

      test('異なる日付の TaskDeadline は等しくないこと', () {
        final date1 = DateTime(2030, 12, 31);
        final date2 = DateTime(2030, 12, 30);
        final deadline1 = TaskDeadline(date1);
        final deadline2 = TaskDeadline(date2);
        expect(deadline1, isNot(equals(deadline2)));
      });

      test('同じ日付の TaskDeadline は同じハッシュコードを持つこと', () {
        final date = DateTime(2030, 12, 31);
        final deadline1 = TaskDeadline(date);
        final deadline2 = TaskDeadline(date);
        expect(deadline1.hashCode, equals(deadline2.hashCode));
      });
    });

    group('日付比較', () {
      test('指定日付より後の日付か判定できること', () {
        final date1 = DateTime(2030, 12, 31);
        final date2 = DateTime(2031, 1, 1);
        final deadline1 = TaskDeadline(date1);
        final deadline2 = TaskDeadline(date2);
        expect(deadline2.isAfter(deadline1), true);
      });

      test('指定日付より前の日付か判定できること', () {
        final date1 = DateTime(2030, 12, 31);
        final date2 = DateTime(2031, 1, 1);
        final deadline1 = TaskDeadline(date1);
        final deadline2 = TaskDeadline(date2);
        expect(deadline1.isBefore(deadline2), true);
      });
    });
  });
}
