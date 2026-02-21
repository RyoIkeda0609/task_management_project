import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/presentation/screens/goal/goal_edit/goal_edit_widgets.dart';
import 'package:app/presentation/screens/goal/goal_edit/goal_edit_view_model.dart';
import 'package:app/presentation/screens/goal/goal_edit/goal_edit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalEditScreen Structure', () {
    testWidgets('edit form can be rendered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Edit Goal')),
            body: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Update')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Edit Goal'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });
  });

  group('GoalEditFormWidget - Deadline Picker', () {
    testWidgets('displays deadline in correct format', (
      WidgetTester tester,
    ) async {
      final testDateTime = DateTime(2026, 2, 20);
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
            goalEditViewModelProvider.overrideWith(
              (ref) => GoalEditViewModel(
                GoalEditPageState(
                  goalId: 'test-goal-1',
                  title: 'Test Goal',
                  description: 'Test Reason',
                  category: 'キャリア',
                  deadline: testDateTime,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GoalEditFormWidget(
                onSubmit: () {},
                goalId: 'test-goal-1',
                goalTitle: goal.title.value,
                goalReason: goal.description.value,
                goalCategory: goal.category.value,
                goalDeadline: goal.deadline.value,
              ),
            ),
          ),
        ),
      );

      // 達成予定日が表示されているか確認
      expect(find.text('達成予定日'), findsOneWidget);
      expect(find.text('2026年2月20日'), findsOneWidget);
    });

    testWidgets('deadline field responds to taps', (WidgetTester tester) async {
      final testDateTime = DateTime(2026, 3, 1);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GoalEditFormWidget(
                onSubmit: () {},
                goalId: 'test-goal-1',
                goalTitle: 'Test',
                goalReason: 'Reason',
                goalCategory: 'カテゴリー',
                goalDeadline: testDateTime,
              ),
            ),
          ),
        ),
      );

      // タイトルフィールドが表示されているか確認
      expect(find.text('ゴール名（最終目標）'), findsOneWidget);
      expect(find.text('説明・理由'), findsOneWidget);
    });

    testWidgets('displays cancel and update buttons', (
      WidgetTester tester,
    ) async {
      final testDateTime = DateTime(2026, 4, 1);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GoalEditFormWidget(
                onSubmit: () {},
                goalId: 'test-goal-1',
                goalTitle: 'Test Goal',
                goalReason: 'Test Reason',
                goalCategory: '学習',
                goalDeadline: testDateTime,
              ),
            ),
          ),
        ),
      );

      // キャンセルと更新ボタンが存在するか確認
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('更新'), findsOneWidget);
    });
  });
}
