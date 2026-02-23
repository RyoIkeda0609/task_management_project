import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';

void main() {
  group('制約検証テスト', () {
    group('ゴール作成の制約', () {
      test('ゴールのデッドラインは過去の日付も許容する（システム日付が進むため）', () async {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        // システム日付が進むと、設定済みのゴール・マイルストーン・タスクの
        // デッドラインが過去になる可能性があり、これらをサポートする必要がある
        expect(() => ItemDeadline(yesterday), returnsNormally);
      });

      test('本日のデッドラインは有効', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(() => ItemDeadline(today), returnsNormally);
      });

      test('明日のデッドラインは有効', () {
        // Arrange
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        // Act & Assert
        expect(() => ItemDeadline(tomorrow), returnsNormally);
      });

      test('ゴールのタイトルが空でないこと', () {
        // Act & Assert
        expect(() => ItemTitle(''), throwsA(isA<ArgumentError>()));
      });

      test('ゴールのタイトルが100文字以下であること', () {
        // Arrange
        final longTitle = 'a' * 101;

        // Act & Assert
        expect(() => ItemTitle(longTitle), throwsA(isA<ArgumentError>()));
      });

      test('ゴールのタイトルが1文字なら有効', () {
        // Act & Assert
        expect(() => ItemTitle('a'), returnsNormally);
      });

      test('ゴールのタイトルが100文字なら有効', () {
        // Arrange
        final title100chars = 'a' * 100;

        // Act & Assert
        expect(() => ItemTitle(title100chars), returnsNormally);
      });

      test('ゴールのカテゴリが空でないこと', () {
        // Act & Assert
        expect(() => GoalCategory(''), throwsA(isA<ArgumentError>()));
      });

      test('ゴールの理由は空文字を許容する（ItemDescriptionは空を許可）', () {
        // Act & Assert - ItemDescription allows empty strings
        expect(() => ItemDescription(''), returnsNormally);
      });
    });

    group('マイルストーン作成の制約', () {
      test('マイルストーンのタイトルが空でないこと', () {
        // Act & Assert
        expect(() => ItemTitle(''), throwsA(isA<ArgumentError>()));
      });

      test('マイルストーンのタイトルが100文字以下であること', () {
        // Arrange
        final longTitle = 'a' * 101;

        // Act & Assert
        expect(() => ItemTitle(longTitle), throwsA(isA<ArgumentError>()));
      });

      test('マイルストーンのタイトルが100文字なら有効', () {
        // Arrange
        final title100chars = 'a' * 100;

        // Act & Assert
        expect(() => ItemTitle(title100chars), returnsNormally);
      });

      test('マイルストーンのデッドラインは過去の日付も許容する（システム日付が進むため）', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        // システム日付が進むと、設定済みのマイルストーンの
        // デッドラインが過去になる可能性があり、これらをサポートする必要がある
        expect(() => ItemDeadline(yesterday), returnsNormally);
      });

      test('本日のデッドラインは有効', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(() => ItemDeadline(today), returnsNormally);
      });
    });

    group('タスク作成の制約', () {
      test('タスクのタイトルが空でないこと', () {
        // Act & Assert -値Object レベルでは空文字を許可しない
        expect(() => ItemTitle(''), throwsA(isA<ArgumentError>()));
      });

      test('タスクのタイトルが100文字以下であること', () {
        // Arrange
        final longTitle = 'a' * 101;

        // Act & Assert
        expect(() => ItemTitle(longTitle), throwsA(isA<ArgumentError>()));
      });

      test('タスクの説明は任意フィールド（空文字許容）', () {
        // ValueObject は任意を許容
        final description = ItemDescription('');
        expect(description.value, '');
      });

      test('タスクの説明が500文字なら有効', () {
        // Arrange
        final description500chars = 'a' * 500;

        // Act & Assert - ValueObject は长い値も許容
        final description = ItemDescription(description500chars);
        expect(description.value.length, 500);
      });

      test('タスクの説明が501文字の場合は ArgumentError が発生', () {
        // Arrange
        final longDescription = 'a' * 501;

        // Act & Assert - ItemDescription は500文字制限あり
        expect(
          () => ItemDescription(longDescription),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('タスクのデッドラインは過去の日付も許容する（システム日付が進むため）', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        // システム日付が進むと、設定済みのタスクの
        // デッドラインが過去になる可能性があり、これらをサポートする必要がある
        expect(() => ItemDeadline(yesterday), returnsNormally);
      });

      test('本日のデッドラインは有効', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(() => ItemDeadline(today), returnsNormally);
      });
    });

    group('階層的デッドライン検証', () {
      test('MS デッドライン >= Goal デッドラインの場合は Goal 側から見ると制約違反', () {
        // Arrange
        final goalDeadline = DateTime.now().add(const Duration(days: 30));
        final msDeadlineEqual = goalDeadline;
        final msDeadlineAfter = DateTime.now().add(const Duration(days: 60));

        // Act & Assert
        // Goal Deadline: 2024-12-30
        // MS Deadline: 2024-12-30 (同じ日時) または 2025-01-29 (後)
        // これらは ValueObject 個別では有効だが、
        // ビジネスロジックでは MS <= Goal が必要

        // ここではロジック層テストではなく ValueObject のみテスト
        expect(() => ItemDeadline(goalDeadline), returnsNormally);
        expect(() => ItemDeadline(msDeadlineEqual), returnsNormally);
        expect(() => ItemDeadline(msDeadlineAfter), returnsNormally);
      });
    });

    group('複合制約検証', () {
      test('最大長制約の境界値テスト: Goal タイトル', () {
        // 99文字: 有効
        expect(() => ItemTitle('a' * 99), returnsNormally);
        // 100文字: 有効
        expect(() => ItemTitle('a' * 100), returnsNormally);
        // 101文字: 無効
        expect(() => ItemTitle('a' * 101), throwsA(isA<ArgumentError>()));
      });

      test('最大長制約の境界値テスト: Task 説明', () {
        // ItemDescription は500文字制限あり
        // 499文字: 有効
        expect(() => ItemDescription('a' * 499), returnsNormally);
        // 500文字: 有効
        expect(() => ItemDescription('a' * 500), returnsNormally);
        // 501文字: 無効（500文字超過）
        expect(() => ItemDescription('a' * 501), throwsA(isA<ArgumentError>()));
      });

      test('複数制約の同時検証: Goal', () {
        // 有効な組み合わせ
        final validTitle = ItemTitle('有効なゴール');
        final validCategory = GoalCategory('仕事');
        final validReason = ItemDescription('スキル向上のため');
        final validDeadline = ItemDeadline(
          DateTime.now().add(const Duration(days: 365)),
        );

        expect(validTitle.value, '有効なゴール');
        expect(validCategory.value, '仕事');
        expect(validReason.value, 'スキル向上のため');
        expect(validDeadline.value, isNotNull);
      });
    });
  });
}
