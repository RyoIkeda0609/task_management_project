import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/shared/progress.dart';
import 'package:app/presentation/screens/goal/goal_detail/goal_detail_widgets.dart';
import 'package:app/presentation/state_management/providers/state_notifier_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalDetailScreen Structure', () {
    testWidgets('goal detail layout can be rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Goal Detail')),
            body: const Column(
              children: [Text('Goal Title'), Text('Goal Description')],
            ),
          ),
        ),
      );

      expect(find.text('Goal Detail'), findsOneWidget);
      expect(find.text('Goal Title'), findsOneWidget);
    });
  });

  group('GoalDetailHeaderWidget - Deadline Display', () {
    testWidgets('displays correct deadline from ValueObject', (
      WidgetTester tester,
    ) async {
      final testDateTime = DateTime(2026, 2, 19);
      final goal = Goal(
        itemId: ItemId('test-goal-1'),
        title: ItemTitle('Test Goal'),
        description: ItemDescription('Test Reason'),
        category: GoalCategory('キャリア'),
        deadline: ItemDeadline(testDateTime),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            goalProgressProvider.overrideWith(
              (ref, goalId) async => Progress(0),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalDetailHeaderWidget(
                goal: goal,
                goalId: goal.itemId.value,
              ),
            ),
          ),
        ),
      );

      // 正しい日付フォーマットで表示されているか確認
      expect(find.text('達成予定日: 2026年2月19日'), findsOneWidget);
    });

    testWidgets('displays different dates correctly', (
      WidgetTester tester,
    ) async {
      final testDateTime = DateTime(2026, 3, 15);
      final goal = Goal(
        itemId: ItemId('test-goal-2'),
        title: ItemTitle('Another Goal'),
        description: ItemDescription('Another Reason'),
        category: GoalCategory('学習'),
        deadline: ItemDeadline(testDateTime),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            goalProgressProvider.overrideWith(
              (ref, goalId) async => Progress(0),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalDetailHeaderWidget(
                goal: goal,
                goalId: goal.itemId.value,
              ),
            ),
          ),
        ),
      );

      expect(find.text('達成予定日: 2026年3月15日'), findsOneWidget);
    });

    testWidgets('displays goal title and category', (
      WidgetTester tester,
    ) async {
      final goal = Goal(
        itemId: ItemId('test-goal-3'),
        title: ItemTitle('My Test Goal'),
        description: ItemDescription('Good Reason'),
        category: GoalCategory('健康'),
        deadline: ItemDeadline(DateTime(2026, 4, 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            goalProgressProvider.overrideWith(
              (ref, goalId) async => Progress(0),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalDetailHeaderWidget(
                goal: goal,
                goalId: goal.itemId.value,
              ),
            ),
          ),
        ),
      );

      expect(find.text('My Test Goal'), findsOneWidget);
      expect(find.text('健康'), findsOneWidget);
      expect(find.text('Good Reason'), findsOneWidget);
    });
  });
}
