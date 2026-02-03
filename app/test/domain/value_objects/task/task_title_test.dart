import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/task/task_title.dart';

void main() {
  group('TaskTitle', () {
    group('コンストラクタ', () {
      test('有効なタイトル（1～100文字）で TaskTitle が生成できること', () {
        final title = TaskTitle('英語の勉強');
        expect(title.value, '英語の勉強');
      });

      test('1文字のタイトルで TaskTitle が生成できること', () {
        final title = TaskTitle('a');
        expect(title.value, 'a');
      });

      test('100文字のタイトルで TaskTitle が生成できること', () {
        final longTitle = 'a' * 100;
        final title = TaskTitle(longTitle);
        expect(title.value, longTitle);
      });
    });

    group('バリデーション', () {
      test('空文字列でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => TaskTitle(''), throwsArgumentError);
      });

      test('100文字を超えるタイトルでコンストラクタを呼び出すと例外が発生すること', () {
        final tooLongTitle = 'a' * 101;
        expect(() => TaskTitle(tooLongTitle), throwsArgumentError);
      });

      test('空白のみのタイトルでコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => TaskTitle('   '), throwsArgumentError);
      });
    });

    group('等価性', () {
      test('同じタイトルの TaskTitle は等しいこと', () {
        final title1 = TaskTitle('テスト');
        final title2 = TaskTitle('テスト');
        expect(title1, equals(title2));
      });

      test('異なるタイトルの TaskTitle は等しくないこと', () {
        final title1 = TaskTitle('テスト1');
        final title2 = TaskTitle('テスト2');
        expect(title1, isNot(equals(title2)));
      });

      test('同じタイトルの TaskTitle は同じハッシュコードを持つこと', () {
        final title1 = TaskTitle('テスト');
        final title2 = TaskTitle('テスト');
        expect(title1.hashCode, equals(title2.hashCode));
      });
    });
  });
}
