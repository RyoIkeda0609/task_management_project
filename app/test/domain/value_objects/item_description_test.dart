import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_description.dart';

void main() {
  group('ItemDescription', () {
    group('初期化', () {
      test('通常の文字列でItemDescriptionが生成できること', () {
        const description = 'これは説明文です';
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });

      test('空文字列は有効であること', () {
        final itemDesc = ItemDescription('');
        expect(itemDesc.value, '');
      });

      test('500文字の説明文は有効であること（最大境界値）', () {
        final description = 'a' * 500;
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });

      test('501文字の説明文ではArgumentErrorが発生すること', () {
        final description = 'a' * 501;
        expect(() => ItemDescription(description), throwsArgumentError);
      });

      test('空白のみの文字列は有効であること', () {
        final itemDesc = ItemDescription('   ');
        expect(itemDesc.value, '   ');
      });

      test('改行やタブを含む文字列は有効であること', () {
        const description = '行1\n行2\n\n行4\t タブ\tあり';
        final itemDesc = ItemDescription(description);
        expect(itemDesc.value, description);
      });
    });

    group('isNotEmptyヘルパー', () {
      test('内容がある説明文ではtrueを返すこと', () {
        final itemDesc = ItemDescription('説明文あり');
        expect(itemDesc.isNotEmpty, true);
      });

      test('空文字列ではfalseを返すこと', () {
        final itemDesc = ItemDescription('');
        expect(itemDesc.isNotEmpty, false);
      });

      test('空白のみの文字列ではfalseを返すこと', () {
        final itemDesc = ItemDescription('   ');
        expect(itemDesc.isNotEmpty, false);
      });

      test('空白を除くと内容がある文字列ではtrueを返すこと', () {
        final itemDesc = ItemDescription('   内容あり   ');
        expect(itemDesc.isNotEmpty, true);
      });
    });

    group('等価性とハッシュコード', () {
      test('同じ値のItemDescriptionは等しいこと', () {
        const descValue = '同じ説明文';
        final desc1 = ItemDescription(descValue);
        final desc2 = ItemDescription(descValue);
        expect(desc1, desc2);
      });

      test('異なる値のItemDescriptionは等しくないこと', () {
        final desc1 = ItemDescription('説明1');
        final desc2 = ItemDescription('説明2');
        expect(desc1, isNot(desc2));
      });

      test('等しいItemDescriptionは同じハッシュコードを持つこと', () {
        const descValue = '同じ説明文';
        final desc1 = ItemDescription(descValue);
        final desc2 = ItemDescription(descValue);
        expect(desc1.hashCode, desc2.hashCode);
      });

      test('Setの中で正しく重複排除されること', () {
        final desc1 = ItemDescription('説明1');
        final desc2 = ItemDescription('説明1');
        final desc3 = ItemDescription('説明2');
        final set = {desc1, desc2, desc3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('toStringがItemDescriptionと値を含む文字列を返すこと', () {
        final desc = ItemDescription('テスト説明');
        expect(desc.toString(), contains('ItemDescription'));
        expect(desc.toString(), contains('テスト説明'));
      });
    });

    group('maxLength定数', () {
      test('maxLengthが500であること', () {
        expect(ItemDescription.maxLength, 500);
      });
    });
  });
}
