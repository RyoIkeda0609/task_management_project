import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';

void main() {
  group('GoalReason', () {
    group('コンストラクタ', () {
      test('有効な理由で GoalReason が生成できること', () {
        final reason = GoalReason('キャリアアップのため');
        expect(reason.value, 'キャリアアップのため');
      });

      test('1文字の理由で GoalReason が生成できること', () {
        final reason = GoalReason('a');
        expect(reason.value, 'a');
      });

      test('100文字の理由で GoalReason が生成できること', () {
        final longReason = 'a' * 100;
        final reason = GoalReason(longReason);
        expect(reason.value, longReason);
      });
    });

    group('バリデーション', () {
      test('空文字列でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => GoalReason(''), throwsArgumentError);
      });

      test('100文字を超える理由でコンストラクタを呼び出すと例外が発生すること', () {
        final tooLongReason = 'a' * 101;
        expect(() => GoalReason(tooLongReason), throwsArgumentError);
      });

      test('空白のみの理由でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => GoalReason('   '), throwsArgumentError);
      });
    });

    group('等価性', () {
      test('同じ理由の GoalReason は等しいこと', () {
        final reason1 = GoalReason('テスト');
        final reason2 = GoalReason('テスト');
        expect(reason1, equals(reason2));
      });

      test('異なる理由の GoalReason は等しくないこと', () {
        final reason1 = GoalReason('理由1');
        final reason2 = GoalReason('理由2');
        expect(reason1, isNot(equals(reason2)));
      });

      test('同じ理由の GoalReason は同じハッシュコードを持つこと', () {
        final reason1 = GoalReason('テスト');
        final reason2 = GoalReason('テスト');
        expect(reason1.hashCode, equals(reason2.hashCode));
      });
    });
  });
}
