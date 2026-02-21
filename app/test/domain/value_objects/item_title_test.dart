import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_title.dart';

void main() {
  group('ItemTitle', () {
    group('初期化', () {
      test('有効なタイトルでItemTitleが生成できること', () {
        const title = 'タスクタイトル';
        final itemTitle = ItemTitle(title);
        expect(itemTitle.value, title);
      });

      test('空白を含む文字列は値がそのまま保存されること（バリデーションはtrim後で評価）', () {
        const title = '  タスクタイトル  ';
        final itemTitle = ItemTitle(title);
        expect(itemTitle.value, title);
        expect(itemTitle.value.trim(), 'タスクタイトル');
      });

      test('1文字のタイトルは有効であること（最小境界値）', () {
        final itemTitle = ItemTitle('A');
        expect(itemTitle.value, 'A');
      });

      test('100文字のタイトルは有効であること（最大境界値）', () {
        final title = 'a' * 100;
        final itemTitle = ItemTitle(title);
        expect(itemTitle.value, title);
      });

      test('空文字列ではArgumentErrorが発生すること', () {
        expect(() => ItemTitle(''), throwsArgumentError);
      });

      test('空白のみの文字列ではArgumentErrorが発生すること', () {
        expect(() => ItemTitle('   '), throwsArgumentError);
      });

      test('101文字のタイトルではArgumentErrorが発生すること', () {
        final title = 'a' * 101;
        expect(() => ItemTitle(title), throwsArgumentError);
      });
    });

    group('等価性とハッシュコード', () {
      test('同じ値のItemTitleは等しいこと', () {
        const titleValue = '同じタイトル';
        final title1 = ItemTitle(titleValue);
        final title2 = ItemTitle(titleValue);
        expect(title1, title2);
      });

      test('異なる値のItemTitleは等しくないこと', () {
        final title1 = ItemTitle('タイトル1');
        final title2 = ItemTitle('タイトル2');
        expect(title1, isNot(title2));
      });

      test('等しいItemTitleは同じハッシュコードを持つこと', () {
        const titleValue = '同じタイトル';
        final title1 = ItemTitle(titleValue);
        final title2 = ItemTitle(titleValue);
        expect(title1.hashCode, title2.hashCode);
      });

      test('Setの中で正しく重複排除されること', () {
        final title1 = ItemTitle('タイトル1');
        final title2 = ItemTitle('タイトル1');
        final title3 = ItemTitle('タイトル2');
        final set = {title1, title2, title3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toStringがItemTitleと値を含む文字列を返すこと', () {
        final title = ItemTitle('テストタイトル');
        expect(title.toString(), contains('ItemTitle'));
        expect(title.toString(), contains('テストタイトル'));
      });
    });

    group('maxLength定数', () {
      test('maxLengthが100であること', () {
        expect(ItemTitle.maxLength, 100);
      });
    });
  });
}
