import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/task/task_description.dart';

void main() {
  group('TaskDescription', () {
    group('コンストラクタ', () {
      test('有効な説明（1～500文字）で TaskDescription が生成できること', () {
        final description = TaskDescription('これはタスクの説明です');
        expect(description.value, 'これはタスクの説明です');
      });

      test('1文字の説明で TaskDescription が生成できること', () {
        final description = TaskDescription('a');
        expect(description.value, 'a');
      });

      test('500文字の説明で TaskDescription が生成できること', () {
        final longDescription = 'a' * 500;
        final description = TaskDescription(longDescription);
        expect(description.value, longDescription);
      });
    });

    group('バリデーション', () {
      test('空文字列でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => TaskDescription(''), throwsArgumentError);
      });

      test('500文字を超える説明でコンストラクタを呼び出すと例外が発生すること', () {
        final tooLongDescription = 'a' * 501;
        expect(() => TaskDescription(tooLongDescription), throwsArgumentError);
      });

      test('空白のみの説明でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => TaskDescription('   '), throwsArgumentError);
      });
    });

    group('等価性', () {
      test('同じ説明の TaskDescription は等しいこと', () {
        final description1 = TaskDescription('テスト');
        final description2 = TaskDescription('テスト');
        expect(description1, equals(description2));
      });

      test('異なる説明の TaskDescription は等しくないこと', () {
        final description1 = TaskDescription('説明1');
        final description2 = TaskDescription('説明2');
        expect(description1, isNot(equals(description2)));
      });

      test('同じ説明の TaskDescription は同じハッシュコードを持つこと', () {
        final description1 = TaskDescription('テスト');
        final description2 = TaskDescription('テスト');
        expect(description1.hashCode, equals(description2.hashCode));
      });
    });
  });
}
