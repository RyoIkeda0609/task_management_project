import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';

void main() {
  group('GoalDeadline', () {
    group('コンストラクタ', () {
      test('本日より後の日付で GoalDeadline が生成できること', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final deadline = GoalDeadline(tomorrow);
        // 時刻を除いて比較（年月日のみ）
        expect(deadline.value.year, tomorrow.year);
        expect(deadline.value.month, tomorrow.month);
        expect(deadline.value.day, tomorrow.day);
      });

      test('遠い将来の日付で GoalDeadline が生成できること', () {
        final futureDate = DateTime(2030, 12, 31);
        final deadline = GoalDeadline(futureDate);
        expect(deadline.value.year, 2030);
        expect(deadline.value.month, 12);
        expect(deadline.value.day, 31);
      });
    });

    group('バリデーション', () {
      test('本日以前の日付でもコンストラクタが動作すること（システム日付が進むため）', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(() => GoalDeadline(yesterday), returnsNormally);
      });

      test('本日の日付で GoalDeadline が生成できること', () {
        final today = DateTime.now();
        final deadline = GoalDeadline(today);
        // 時刻を除いて比較（年月日のみ）
        expect(deadline.value.year, today.year);
        expect(deadline.value.month, today.month);
        expect(deadline.value.day, today.day);
      });

      test('過去の日付でもコンストラクタが動作すること（システム日付が進むため）', () {
        final pastDate = DateTime(2020, 1, 1);
        expect(() => GoalDeadline(pastDate), returnsNormally);
      });
    });

    group('等価性', () {
      test('同じ日付の GoalDeadline は等しいこと', () {
        final date = DateTime(2030, 12, 31);
        final deadline1 = GoalDeadline(date);
        final deadline2 = GoalDeadline(date);
        expect(deadline1, equals(deadline2));
      });

      test('異なる日付の GoalDeadline は等しくないこと', () {
        final date1 = DateTime(2030, 12, 31);
        final date2 = DateTime(2030, 12, 30);
        final deadline1 = GoalDeadline(date1);
        final deadline2 = GoalDeadline(date2);
        expect(deadline1, isNot(equals(deadline2)));
      });

      test('同じ日付の GoalDeadline は同じハッシュコードを持つこと', () {
        final date = DateTime(2030, 12, 31);
        final deadline1 = GoalDeadline(date);
        final deadline2 = GoalDeadline(date);
        expect(deadline1.hashCode, equals(deadline2.hashCode));
      });
    });

    group('日付比較', () {
      test('指定日付より後の日付か判定できること', () {
        final date1 = DateTime(2030, 12, 31);
        final date2 = DateTime(2031, 1, 1);
        final deadline1 = GoalDeadline(date1);
        final deadline2 = GoalDeadline(date2);
        expect(deadline2.isAfter(deadline1), true);
      });

      test('指定日付より前の日付か判定できること', () {
        final date1 = DateTime(2030, 12, 31);
        final date2 = DateTime(2031, 1, 1);
        final deadline1 = GoalDeadline(date1);
        final deadline2 = GoalDeadline(date2);
        expect(deadline1.isBefore(deadline2), true);
      });
    });
  });
}
