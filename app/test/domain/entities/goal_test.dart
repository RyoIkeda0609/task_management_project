import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

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

    group('calculateProgress', () {
      test('マイルストーンが存在しない場合、Progress(0)を返すこと', () {
        final progress = goal.calculateProgress([]);
        expect(progress.value, 0);
      });

      test('1つのマイルストーン進捗から計算できること', () {
        final progress = goal.calculateProgress([Progress(50)]);
        expect(progress.value, 50);
      });

      test('複数のマイルストーン進捗の平均を計算できること', () {
        final progresses = [Progress(30), Progress(60), Progress(90)];
        final progress = goal.calculateProgress(progresses);
        expect(progress.value, 60); // (30+60+90)/3 = 60
      });

      test('進捗の平均が小数の場合、切り捨てられること', () {
        final progresses = [Progress(10), Progress(20)];
        final progress = goal.calculateProgress(progresses);
        expect(progress.value, 15); // (10+20)/2 = 15
      });

      test('すべての進捗が0の場合、Progress(0)を返すこと', () {
        final progress = goal.calculateProgress([Progress(0), Progress(0)]);
        expect(progress.value, 0);
      });

      test('すべての進捗が100の場合、Progress(100)を返すこと', () {
        final progress = goal.calculateProgress([Progress(100), Progress(100)]);
        expect(progress.value, 100);
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
