import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';

void main() {
  group('Goal Entity', () {
    late Goal goal;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('プログラミング習得'),
        category: GoalCategory('スキル'),
        reason: GoalReason('キャリアアップのため'),
        deadline: GoalDeadline(tomorrow),
      );
    });

    group('初期化', () {
      test('ゴールが正しく初期化できること', () {
        expect(goal.id.value, 'goal-1');
        expect(goal.title.value, 'プログラミング習得');
        expect(goal.category.value, 'スキル');
        expect(goal.reason.value, 'キャリアアップのため');
      });

      test('必須フィールドなしでは初期化できないこと', () {
        expect(
          () => Goal(
            id: GoalId('goal-2'),
            title: GoalTitle('テスト'),
            category: GoalCategory('テスト'),
            reason: GoalReason('テスト'),
            deadline: GoalDeadline(tomorrow),
          ),
          returnsNormally,
        );
      });
    });

    group('等号演算子とhashCode', () {
      test('同じフィールドを持つGoalは等価であること', () {
        final goal2 = Goal(
          id: GoalId('goal-1'),
          title: GoalTitle('プログラミング習得'),
          category: GoalCategory('スキル'),
          reason: GoalReason('キャリアアップのため'),
          deadline: GoalDeadline(tomorrow),
        );
        expect(goal, goal2);
      });

      test('異なるIDを持つGoalは等価でないこと', () {
        final goal2 = Goal(
          id: GoalId('goal-2'),
          title: GoalTitle('プログラミング習得'),
          category: GoalCategory('スキル'),
          reason: GoalReason('キャリアアップのため'),
          deadline: GoalDeadline(tomorrow),
        );
        expect(goal, isNot(goal2));
      });

      test('異なるタイトルを持つGoalは等価でないこと', () {
        final goal2 = Goal(
          id: GoalId('goal-1'),
          title: GoalTitle('Flutterマスター'),
          category: GoalCategory('スキル'),
          reason: GoalReason('キャリアアップのため'),
          deadline: GoalDeadline(tomorrow),
        );
        expect(goal, isNot(goal2));
      });

      test('同じGoalはHashCodeが同じであること', () {
        final goal2 = Goal(
          id: GoalId('goal-1'),
          title: GoalTitle('プログラミング習得'),
          category: GoalCategory('スキル'),
          reason: GoalReason('キャリアアップのため'),
          deadline: GoalDeadline(tomorrow),
        );
        expect(goal.hashCode, goal2.hashCode);
      });
    });

    group('toString', () {
      test('toStringが適切な文字列を返すこと', () {
        final string = goal.toString();
        expect(string, contains('Goal'));
        expect(string, contains('goal-1'));
        expect(string, contains('プログラミング習得'));
      });
    });
  });
}
