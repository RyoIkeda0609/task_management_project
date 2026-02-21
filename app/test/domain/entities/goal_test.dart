import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';

void main() {
  group('Goal Entity', () {
    late Goal goal;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      goal = Goal(
        itemId: ItemId('goal-1'),
        title: ItemTitle('プログラミング習得'),
        description: ItemDescription('キャリアアップのため'),
        deadline: ItemDeadline(tomorrow),
        category: GoalCategory('スキル'),
      );
    });

    group('初期化', () {
      test('ゴールが正しく初期化できること', () {
        expect(goal.itemId.value, 'goal-1');
        expect(goal.title.value, 'プログラミング習得');
        expect(goal.category.value, 'スキル');
        expect(goal.description.value, 'キャリアアップのため');
      });

      test('必須フィールドなしでは初期化できないこと', () {
        expect(
          () => Goal(
            itemId: ItemId('goal-2'),
            title: ItemTitle('テスト'),
            description: ItemDescription('テスト'),
            deadline: ItemDeadline(tomorrow),
            category: GoalCategory('テスト'),
          ),
          returnsNormally,
        );
      });
    });

    group('等号演算子とhashCode', () {
      test('同じフィールドを持つGoalは等価であること', () {
        final goal2 = Goal(
          itemId: ItemId('goal-1'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('キャリアアップのため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal, goal2);
      });

      test('異なるIDを持つGoalは等価でないこと', () {
        final goal2 = Goal(
          itemId: ItemId('goal-2'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('キャリアアップのため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal, isNot(goal2));
      });

      test('異なるタイトルを持つGoalは等価でないこと', () {
        final goal2 = Goal(
          itemId: ItemId('goal-1'),
          title: ItemTitle('Flutterマスター'),
          description: ItemDescription('キャリアアップのため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal, isNot(goal2));
      });

      test('同じGoalはHashCodeが同じであること', () {
        final goal2 = Goal(
          itemId: ItemId('goal-1'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('キャリアアップのため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
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
