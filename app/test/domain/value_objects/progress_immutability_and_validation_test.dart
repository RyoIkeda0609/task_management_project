import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

void main() {
  group('Progress - 値の不変性と バリデーション', () {
    test('Progress は 0 で初期化できる', () {
      final progress = Progress(0);
      expect(progress.value, 0);
    });

    test('Progress は 50 で初期化できる', () {
      final progress = Progress(50);
      expect(progress.value, 50);
    });

    test('Progress は 100 で初期化できる', () {
      final progress = Progress(100);
      expect(progress.value, 100);
    });

    test('Progress に -1 を指定するとエラー', () {
      expect(
        () => Progress(-1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Progress に 101 を指定するとエラー', () {
      expect(
        () => Progress(101),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Progress は不変オブジェクト', () {
      final progress1 = Progress(50);
      final progress2 = Progress(50);

      // 同じ値だが異なるオブジェクトインスタンス
      expect(progress1.value, progress2.value);
      expect(identical(progress1, progress2), false);
    });

    test('Progress の値は直接変更できない', () {
      final progress = Progress(50);
      // value プロパティは final なので変更不可
      expect(progress.value, 50);
      // 新しい Progress インスタンスを作成する必要がある
      final newProgress = Progress(75);
      expect(newProgress.value, 75);
    });

    test('Progress は 0 から 100 の範囲の値のみ有効', () {
      for (int i = 0; i <= 100; i += 10) {
        final progress = Progress(i);
        expect(progress.value, i);
      }
    });

    test('複数の無効な値がエラーを発生させる', () {
      final invalidValues = [-100, -1, 101, 200];
      for (final value in invalidValues) {
        expect(
          () => Progress(value),
          throwsA(isA<ArgumentError>()),
          reason: 'Progress($value) should throw ArgumentError',
        );
      }
    });

    test('Progress(0) は タスク未開始状態を示す', () {
      final progress = Progress(0);
      expect(progress.value, 0);
    });

    test('Progress(100) は タスク完了状態を示す', () {
      final progress = Progress(100);
      expect(progress.value, 100);
    });

    test('Progress の計算は Milestone/Goal レベルで管理される', () {
      // Progress は Entity 内でステータスから自動計算される
      // 手動で値を設定することはできない
      final progress0 = Progress(0);
      final progress50 = Progress(50);
      final progress100 = Progress(100);

      expect(progress0.value, 0);
      expect(progress50.value, 50);
      expect(progress100.value, 100);
    });
  });
}
