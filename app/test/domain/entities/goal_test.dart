import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';

void main() {
  group('Goal Entity (Refactored with Item)', () {
    late Goal goal;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      goal = Goal(
        itemId: ItemId('goal-1'),
        title: ItemTitle('プログラミング習得'),
        description: ItemDescription('Flutterを深く学ぶため'),
        deadline: ItemDeadline(tomorrow),
        category: GoalCategory('スキル'),
      );
    });

    group('初期化', () {
      test('全フィールドが正しく設定されること', () {
        expect(goal.itemId.value, 'goal-1');
        expect(goal.title.value, 'プログラミング習得');
        expect(goal.description.value, 'Flutterを深く学ぶため');
        expect(goal.category.value, 'スキル');
      });

      test('ItemId.generate()でGoalが生成できること', () {
        final goalWithGeneratedId = Goal(
          itemId: ItemId.generate(),
          title: ItemTitle('New Goal'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('Category'),
        );
        expect(goalWithGeneratedId.itemId.value.isNotEmpty, true);
      });

      test('空の説明文でGoalが生成できること', () {
        final goalEmptyDesc = Goal(
          itemId: ItemId('goal-2'),
          title: ItemTitle('Goal'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('Category'),
        );
        expect(goalEmptyDesc.description.value, '');
      });
    });

    group('等価性とハッシュコード', () {
      test('同じフィールドを持つGoalは等しいこと', () {
        final goal2 = Goal(
          itemId: ItemId('goal-1'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('Flutterを深く学ぶため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal, goal2);
      });

      test('異なるitemIdを持つGoalは等しくないこと', () {
        final goal2 = Goal(
          itemId: ItemId('goal-2'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('Flutterを深く学ぶため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal, isNot(goal2));
      });

      test('等しいGoalは同じハッシュコードを持つこと', () {
        final goal2 = Goal(
          itemId: ItemId('goal-1'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('Flutterを深く学ぶため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal.hashCode, goal2.hashCode);
      });
    });

    group('JSONシリアライズ', () {
      test('toJsonで全フィールドが含まれること', () {
        final json = goal.toJson();
        expect(json['itemId'], 'goal-1');
        expect(json['title'], 'プログラミング習得');
        expect(json['description'], 'Flutterを深く学ぶため');
        expect(json['category'], 'スキル');
        expect(json['deadline'], isNotNull);
      });

      test('fromJsonでGoalが正しく復元できること', () {
        final json = goal.toJson();
        final restored = Goal.fromJson(json);
        expect(restored, goal);
      });

      test('fromJsonで全フィールドが正しく復元できること', () {
        final json = {
          'itemId': 'goal-123',
          'title': 'テストゴール',
          'description': 'テスト説明',
          'deadline': tomorrow.toIso8601String(),
          'category': 'テストカテゴリ',
        };
        final restored = Goal.fromJson(json);
        expect(restored.itemId.value, 'goal-123');
        expect(restored.title.value, 'テストゴール');
        expect(restored.description.value, 'テスト説明');
        expect(restored.category.value, 'テストカテゴリ');
      });
    });

    group('toString', () {
      test('toStringがGoalとitemIdとtitleを含む文字列を返すこと', () {
        final str = goal.toString();
        expect(str, contains('Goal'));
        expect(str, contains('goal-1'));
        expect(str, contains('プログラミング習得'));
      });
    });
  });
}
