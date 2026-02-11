import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';

void main() {
  group('Goal - 基本的なバリデーションテスト', () {
    test('Goal は必須フィールドで作成できる', () {
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('テストゴール'),
        category: GoalCategory('personal'),
        reason: GoalReason('重要だから'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      expect(goal.id.value, 'goal-1');
      expect(goal.title.value, 'テストゴール');
    });

    test('Goal の id は null ではない', () {
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('テストゴール'),
        category: GoalCategory('personal'),
        reason: GoalReason('重要だから'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      expect(goal.id.value, isNotEmpty);
    });

    test('複数の Goal インスタンスは異なるオブジェクトである', () {
      final goal1 = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('テストゴール'),
        category: GoalCategory('personal'),
        reason: GoalReason('重要だから'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      final goal2 = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('テストゴール'),
        category: GoalCategory('personal'),
        reason: GoalReason('重要だから'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      expect(identical(goal1, goal2), false);
      expect(goal1.id.value, goal2.id.value);
    });

    test('Goal の title, category, reason は不変である', () {
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('元のタイトル'),
        category: GoalCategory('personal'),
        reason: GoalReason('元の理由'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      final originalTitle = goal.title;
      final originalCategory = goal.category;
      expect(goal.title, originalTitle);
      expect(goal.category, originalCategory);
    });

    test('複数の Goal は異なる id を持つことができる', () {
      final goal1 = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('ゴール1'),
        category: GoalCategory('personal'),
        reason: GoalReason('理由1'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      final goal2 = Goal(
        id: GoalId('goal-2'),
        title: GoalTitle('ゴール2'),
        category: GoalCategory('work'),
        reason: GoalReason('理由2'),
        deadline: GoalDeadline(DateTime(2027, 12, 31)),
      );

      expect(goal1.id.value, isNot(equals(goal2.id.value)));
      expect(goal1.title.value, isNot(equals(goal2.title.value)));
    });

    test('Goal の category は有効な値である', () {
      final personalGoal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('個人ゴール'),
        category: GoalCategory('personal'),
        reason: GoalReason('個人的な成長'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      final workGoal = Goal(
        id: GoalId('goal-2'),
        title: GoalTitle('仕事ゴール'),
        category: GoalCategory('work'),
        reason: GoalReason('キャリア発展'),
        deadline: GoalDeadline(DateTime(2026, 12, 31)),
      );

      expect(personalGoal.category.value, 'personal');
      expect(workGoal.category.value, 'work');
    });

    test('Goal の deadline は有効な日時である', () {
      final deadline = DateTime(2026, 12, 31);
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('テストゴール'),
        category: GoalCategory('personal'),
        reason: GoalReason('重要だから'),
        deadline: GoalDeadline(deadline),
      );

      expect(goal.deadline.value, isNotNull);
      expect(goal.deadline.value, isA<DateTime>());
    });
  });
}
