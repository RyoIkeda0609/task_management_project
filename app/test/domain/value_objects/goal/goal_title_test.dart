import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';

void main() {
  group('GoalTitle', () {
    group('コンストラクタ', () {
      test('有効なタイトル（1～100文字）で GoalTitle が生成できること', () {
        final title = GoalTitle('新しいプロジェクト');
        expect(title.value, '新しいプロジェクト');
      });

      test('1文字のタイトルで GoalTitle が生成できること', () {
        final title = GoalTitle('a');
        expect(title.value, 'a');
      });

      test('100文字のタイトルで GoalTitle が生成できること', () {
        final longTitle = 'a' * 100;
        final title = GoalTitle(longTitle);
        expect(title.value, longTitle);
      });
    });

    group('バリデーション', () {
      test('空文字列でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => GoalTitle(''), throwsArgumentError);
      });

      test('100文字を超えるタイトルでコンストラクタを呼び出すと例外が発生すること', () {
        final tooLongTitle = 'a' * 101;
        expect(() => GoalTitle(tooLongTitle), throwsArgumentError);
      });

      test('空白のみのタイトルでコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => GoalTitle('   '), throwsArgumentError);
      });
    });

    group('等価性', () {
      test('同じタイトルの GoalTitle は等しいこと', () {
        final title1 = GoalTitle('テスト');
        final title2 = GoalTitle('テスト');
        expect(title1, equals(title2));
      });

      test('異なるタイトルの GoalTitle は等しくないこと', () {
        final title1 = GoalTitle('テスト1');
        final title2 = GoalTitle('テスト2');
        expect(title1, isNot(equals(title2)));
      });

      test('同じタイトルの GoalTitle は同じハッシュコードを持つこと', () {
        final title1 = GoalTitle('テスト');
        final title2 = GoalTitle('テスト');
        expect(title1.hashCode, equals(title2.hashCode));
      });
    });
  });
}
