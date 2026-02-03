import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

void main() {
  group('Progress', () {
    group('コンストラクタ', () {
      test('0 から 100 までの値で Progress を生成できること', () {
        final progress = Progress(50);
        expect(progress.value, 50);
      });

      test('0 で Progress を生成できること', () {
        final progress = Progress(0);
        expect(progress.value, 0);
      });

      test('100 で Progress を生成できること', () {
        final progress = Progress(100);
        expect(progress.value, 100);
      });
    });

    group('バリデーション', () {
      test('負の値でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => Progress(-1), throwsArgumentError);
      });

      test('100 を超える値でコンストラクタを呼び出すと例外が発生すること', () {
        expect(() => Progress(101), throwsArgumentError);
      });
    });

    group('等価性', () {
      test('同じ値の Progress は等しいこと', () {
        final progress1 = Progress(50);
        final progress2 = Progress(50);
        expect(progress1, equals(progress2));
      });

      test('異なる値の Progress は等しくないこと', () {
        final progress1 = Progress(50);
        final progress2 = Progress(60);
        expect(progress1, isNot(equals(progress2)));
      });

      test('同じ値の Progress は同じハッシュコードを持つこと', () {
        final progress1 = Progress(50);
        final progress2 = Progress(50);
        expect(progress1.hashCode, equals(progress2.hashCode));
      });
    });

    group('判定メソッド', () {
      test('完了状態（progress == 100）を判定できること', () {
        final progress = Progress(100);
        expect(progress.isCompleted, true);
      });

      test('未完了状態（progress < 100）を判定できること', () {
        final progress = Progress(50);
        expect(progress.isCompleted, false);
      });

      test('未開始状態（progress == 0）を判定できること', () {
        final progress = Progress(0);
        expect(progress.isNotStarted, true);
      });

      test('開始状態（progress > 0）を判定できること', () {
        final progress = Progress(10);
        expect(progress.isNotStarted, false);
      });
    });
  });
}
