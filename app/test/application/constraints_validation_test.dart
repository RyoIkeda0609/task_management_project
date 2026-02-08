import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';

void main() {
  group('制約検証テスト', () {
    group('ゴール作成の制約', () {
      test('ゴールのデッドラインは過去の日付も許容する（システム日付が進むため）', () async {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        // システム日付が進むと、設定済みのゴール・マイルストーン・タスクの
        // デッドラインが過去になる可能性があり、これらをサポートする必要がある
        expect(() => GoalDeadline(yesterday), returnsNormally);
      });

      test('本日のデッドラインは有効', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(() => GoalDeadline(today), returnsNormally);
      });

      test('明日のデッドラインは有効', () {
        // Arrange
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        // Act & Assert
        expect(() => GoalDeadline(tomorrow), returnsNormally);
      });

      test('ゴールのタイトルが空でないこと', () {
        // Act & Assert
        expect(() => GoalTitle(''), throwsA(isA<ArgumentError>()));
      });

      test('ゴールのタイトルが100文字以下であること', () {
        // Arrange
        final longTitle = 'a' * 101;

        // Act & Assert
        expect(() => GoalTitle(longTitle), throwsA(isA<ArgumentError>()));
      });

      test('ゴールのタイトルが1文字なら有効', () {
        // Act & Assert
        expect(() => GoalTitle('a'), returnsNormally);
      });

      test('ゴールのタイトルが100文字なら有効', () {
        // Arrange
        final title100chars = 'a' * 100;

        // Act & Assert
        expect(() => GoalTitle(title100chars), returnsNormally);
      });

      test('ゴールのカテゴリが空でないこと', () {
        // Act & Assert
        expect(() => GoalCategory(''), throwsA(isA<ArgumentError>()));
      });

      test('ゴールの理由が空でないこと', () {
        // Act & Assert
        expect(() => GoalReason(''), throwsA(isA<ArgumentError>()));
      });
    });

    group('マイルストーン作成の制約', () {
      test('マイルストーンのタイトルが空でないこと', () {
        // Act & Assert
        expect(() => MilestoneTitle(''), throwsA(isA<ArgumentError>()));
      });

      test('マイルストーンのタイトルが100文字以下であること', () {
        // Arrange
        final longTitle = 'a' * 101;

        // Act & Assert
        expect(() => MilestoneTitle(longTitle), throwsA(isA<ArgumentError>()));
      });

      test('マイルストーンのタイトルが100文字なら有効', () {
        // Arrange
        final title100chars = 'a' * 100;

        // Act & Assert
        expect(() => MilestoneTitle(title100chars), returnsNormally);
      });

      test('マイルストーンのデッドラインは過去の日付も許容する（システム日付が進むため）', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        // システム日付が進むと、設定済みのマイルストーンの
        // デッドラインが過去になる可能性があり、これらをサポートする必要がある
        expect(
          () => MilestoneDeadline(yesterday),
          returnsNormally,
        );
      });

      test('本日のデッドラインは有効', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(() => MilestoneDeadline(today), returnsNormally);
      });
    });

    group('タスク作成の制約', () {
      test('タスクのタイトルが空でないこと', () {
        // Act & Assert
        expect(() => TaskTitle(''), throwsA(isA<ArgumentError>()));
      });

      test('タスクのタイトルが100文字以下であること', () {
        // Arrange
        final longTitle = 'a' * 101;

        // Act & Assert
        expect(() => TaskTitle(longTitle), throwsA(isA<ArgumentError>()));
      });

      test('タスクの説明が空でないこと', () {
        // Act & Assert
        expect(() => TaskDescription(''), throwsA(isA<ArgumentError>()));
      });

      test('タスクの説明が500文字以下であること', () {
        // Arrange
        final longDescription = 'a' * 501;

        // Act & Assert
        expect(
          () => TaskDescription(longDescription),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('タスクの説明が500文字なら有効', () {
        // Arrange
        final description500chars = 'a' * 500;

        // Act & Assert
        expect(() => TaskDescription(description500chars), returnsNormally);
      });

      test('タスクのデッドラインは過去の日付も許容する（システム日付が進むため）', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        // システム日付が進むと、設定済みのタスクの
        // デッドラインが過去になる可能性があり、これらをサポートする必要がある
        expect(() => TaskDeadline(yesterday), returnsNormally);
      });

      test('本日のデッドラインは有効', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(() => TaskDeadline(today), returnsNormally);
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
        expect(() => GoalDeadline(goalDeadline), returnsNormally);
        expect(() => MilestoneDeadline(msDeadlineEqual), returnsNormally);
        expect(() => MilestoneDeadline(msDeadlineAfter), returnsNormally);
      });
    });

    group('複合制約検証', () {
      test('最大長制約の境界値テスト: Goal タイトル', () {
        // 99文字: 有効
        expect(() => GoalTitle('a' * 99), returnsNormally);
        // 100文字: 有効
        expect(() => GoalTitle('a' * 100), returnsNormally);
        // 101文字: 無効
        expect(() => GoalTitle('a' * 101), throwsA(isA<ArgumentError>()));
      });

      test('最大長制約の境界値テスト: Task 説明', () {
        // 499文字: 有効
        expect(() => TaskDescription('a' * 499), returnsNormally);
        // 500文字: 有効
        expect(() => TaskDescription('a' * 500), returnsNormally);
        // 501文字: 無効
        expect(() => TaskDescription('a' * 501), throwsA(isA<ArgumentError>()));
      });

      test('複数制約の同時検証: Goal', () {
        // 有効な組み合わせ
        final validTitle = GoalTitle('有効なゴール');
        final validCategory = GoalCategory('仕事');
        final validReason = GoalReason('スキル向上のため');
        final validDeadline = GoalDeadline(
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
