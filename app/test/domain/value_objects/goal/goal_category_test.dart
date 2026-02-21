import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';

void main() {
  group('GoalCategory', () {
    group('コンストラクタ', () {
      test('有効なカテゴリで GoalCategory が生成できること', () {
        final category = GoalCategory('勉強');
        expect(category.value, '勉強');
      });

      test('1文字のカテゴリは有効であること（最小境界値）', () {
        final category = GoalCategory('A');
        expect(category.value, 'A');
      });

      test('100文字のカテゴリは有効であること（最大境界値）', () {
        final longCategory = 'a' * 100;
        final category = GoalCategory(longCategory);
        expect(category.value, longCategory);
      });

      test('複数の異なるカテゴリで GoalCategory が生成できること', () {
        final categories = ['仕事', '健康', '趣味', '家族'];
        for (final cat in categories) {
          final goalCategory = GoalCategory(cat);
          expect(goalCategory.value, cat);
        }
      });
    });

    group('バリデーション', () {
      test('空文字列でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => GoalCategory(''), throwsArgumentError);
      });

      test('100文字を超えるカテゴリでコンストラクタを呼び出すと例外が発生すること', () {
        final tooLongCategory = 'a' * 101;
        expect(() => GoalCategory(tooLongCategory), throwsArgumentError);
      });

      test('空白のみのカテゴリでコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => GoalCategory('   '), throwsArgumentError);
      });
    });

    group('等価性', () {
      test('同じカテゴリの GoalCategory は等しいこと', () {
        final category1 = GoalCategory('勉強');
        final category2 = GoalCategory('勉強');
        expect(category1, equals(category2));
      });

      test('異なるカテゴリの GoalCategory は等しくないこと', () {
        final category1 = GoalCategory('勉強');
        final category2 = GoalCategory('仕事');
        expect(category1, isNot(equals(category2)));
      });

      test('同じカテゴリの GoalCategory は同じハッシュコードを持つこと', () {
        final category1 = GoalCategory('勉強');
        final category2 = GoalCategory('勉強');
        expect(category1.hashCode, equals(category2.hashCode));
      });
    });
  });
}
