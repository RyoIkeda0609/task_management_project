import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';

void main() {
  group('MilestoneTitle', () {
    group('コンストラクタ', () {
      test('有効なタイトル（1～100文字）で MilestoneTitle が生成できること', () {
        final title = MilestoneTitle('第1ステップ');
        expect(title.value, '第1ステップ');
      });

      test('1文字のタイトルで MilestoneTitle が生成できること', () {
        final title = MilestoneTitle('a');
        expect(title.value, 'a');
      });

      test('100文字のタイトルで MilestoneTitle が生成できること', () {
        final longTitle = 'a' * 100;
        final title = MilestoneTitle(longTitle);
        expect(title.value, longTitle);
      });
    });

    group('バリデーション', () {
      test('空文字列でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => MilestoneTitle(''), throwsArgumentError);
      });

      test('100文字を超えるタイトルでコンストラクタを呼び出すと例外が発生すること', () {
        final tooLongTitle = 'a' * 101;
        expect(() => MilestoneTitle(tooLongTitle), throwsArgumentError);
      });

      test('空白のみのタイトルでコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => MilestoneTitle('   '), throwsArgumentError);
      });
    });

    group('等価性', () {
      test('同じタイトルの MilestoneTitle は等しいこと', () {
        final title1 = MilestoneTitle('テスト');
        final title2 = MilestoneTitle('テスト');
        expect(title1, equals(title2));
      });

      test('異なるタイトルの MilestoneTitle は等しくないこと', () {
        final title1 = MilestoneTitle('テスト1');
        final title2 = MilestoneTitle('テスト2');
        expect(title1, isNot(equals(title2)));
      });

      test('同じタイトルの MilestoneTitle は同じハッシュコードを持つこと', () {
        final title1 = MilestoneTitle('テスト');
        final title2 = MilestoneTitle('テスト');
        expect(title1.hashCode, equals(title2.hashCode));
      });
    });
  });
}
