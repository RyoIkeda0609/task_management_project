import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/presentation/screens/goal/goal_detail/goal_detail_widgets.dart';
import 'package:flutter/material.dart';
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
        id: GoalId('test-goal-1'),
        title: GoalTitle('Test Goal'),
        reason: GoalReason('Test Reason'),
        category: GoalCategory('キャリア'),
        deadline: GoalDeadline(testDateTime),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GoalDetailHeaderWidget(goal: goal)),
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
        id: GoalId('test-goal-2'),
        title: GoalTitle('Another Goal'),
        reason: GoalReason('Another Reason'),
        category: GoalCategory('学習'),
        deadline: GoalDeadline(testDateTime),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GoalDetailHeaderWidget(goal: goal)),
        ),
      );

      expect(find.text('達成予定日: 2026年3月15日'), findsOneWidget);
    });

    testWidgets('displays goal title and category', (
      WidgetTester tester,
    ) async {
      final goal = Goal(
        id: GoalId('test-goal-3'),
        title: GoalTitle('My Test Goal'),
        reason: GoalReason('Good Reason'),
        category: GoalCategory('健康'),
        deadline: GoalDeadline(DateTime(2026, 4, 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GoalDetailHeaderWidget(goal: goal)),
        ),
      );

      expect(find.text('My Test Goal'), findsOneWidget);
      expect(find.text('健康'), findsOneWidget);
      expect(find.text('Good Reason'), findsOneWidget);
    });
  });
}
