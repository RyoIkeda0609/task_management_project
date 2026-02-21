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

    group('initialization', () {
      test('Goal should be initialized with all fields', () {
        expect(goal.itemId.value, 'goal-1');
        expect(goal.title.value, 'プログラミング習得');
        expect(goal.description.value, 'Flutterを深く学ぶため');
        expect(goal.category.value, 'スキル');
      });

      test('Goal can use ItemId.generate()', () {
        final goalWithGeneratedId = Goal(
          itemId: ItemId.generate(),
          title: ItemTitle('New Goal'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('Category'),
        );
        expect(goalWithGeneratedId.itemId.value.isNotEmpty, true);
      });

      test('Goal can accept empty description', () {
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

    group('equality and hashCode', () {
      test('Goals with same fields should be equal', () {
        final goal2 = Goal(
          itemId: ItemId('goal-1'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('Flutterを深く学ぶため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal, goal2);
      });

      test('Goals with different itemId should not be equal', () {
        final goal2 = Goal(
          itemId: ItemId('goal-2'),
          title: ItemTitle('プログラミング習得'),
          description: ItemDescription('Flutterを深く学ぶため'),
          deadline: ItemDeadline(tomorrow),
          category: GoalCategory('スキル'),
        );
        expect(goal, isNot(goal2));
      });

      test('equal Goals should have same hashCode', () {
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

    group('JSON serialization', () {
      test('toJson should include all fields', () {
        final json = goal.toJson();
        expect(json['itemId'], 'goal-1');
        expect(json['title'], 'プログラミング習得');
        expect(json['description'], 'Flutterを深く学ぶため');
        expect(json['category'], 'スキル');
        expect(json['deadline'], isNotNull);
      });

      test('fromJson should restore Goal correctly', () {
        final json = goal.toJson();
        final restored = Goal.fromJson(json);
        expect(restored, goal);
      });

      test('fromJson should handle all fields', () {
        final json = {
          'itemId': 'goal-123',
          'title': 'Test Goal',
          'description': 'Test Description',
          'deadline': tomorrow.toIso8601String(),
          'category': 'Test Category',
        };
        final restored = Goal.fromJson(json);
        expect(restored.itemId.value, 'goal-123');
        expect(restored.title.value, 'Test Goal');
        expect(restored.description.value, 'Test Description');
        expect(restored.category.value, 'Test Category');
      });
    });

    group('toString', () {
      test('toString should include itemId and title', () {
        final str = goal.toString();
        expect(str, contains('Goal'));
        expect(str, contains('goal-1'));
        expect(str, contains('プログラミング習得'));
      });
    });
  });
}
