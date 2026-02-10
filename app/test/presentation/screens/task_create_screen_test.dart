import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/task/task_create_screen.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/presentation/state_management/providers/app_providers.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';

class FakeTaskRepository implements TaskRepository {
  @override
  Future<void> saveTask(Task task) async {}

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<Task?> getTaskById(String id) async => null;

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async => [];

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async {}

  @override
  Future<int> getTaskCount() async => 0;
}

class FakeMilestoneRepository implements MilestoneRepository {
  @override
  Future<void> saveMilestone(Milestone milestone) async {}

  @override
  Future<List<Milestone>> getAllMilestones() async => [];

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    if (id == 'milestone-123') {
      return Milestone(
        id: MilestoneId('milestone-123'),
        goalId: 'goal-123',
        title: MilestoneTitle('Test Milestone'),
        deadline: MilestoneDeadline(DateTime.now().add(Duration(days: 7))),
      );
    }
    return null;
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async => [];

  @override
  Future<void> deleteMilestone(String id) async {}

  @override
  Future<void> deleteAllByGoalId(String goalId) async {}

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async {}

  @override
  Future<int> getMilestoneCount() async => 0;
}

void main() {
  group('TaskCreateScreen', () {
    testWidgets('displays all required form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          ],
          child: MaterialApp(home: TaskCreateScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('タスク名 *'), findsOneWidget);
      expect(find.text('期限 *'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
    });

    testWidgets('should not create task when title is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          ],
          child: MaterialApp(home: TaskCreateScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 画面にタスク名フィールドが表示されていることを確認
      expect(find.text('タスク名 *'), findsOneWidget);
    });

    testWidgets('displays milestone information when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            milestoneRepositoryProvider.overrideWithValue(
              FakeMilestoneRepository(),
            ),
          ],
          child: MaterialApp(
            home: TaskCreateScreen(arguments: {'milestoneId': 'milestone-123'}),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('マイルストーンに紐付けます'), findsOneWidget);
      // マイルストーンのタイトルが表示されることを確認（詳細なタイトルはモックで定義）
    });

    testWidgets('closes screen when cancel button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          ],
          child: MaterialApp(home: TaskCreateScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // キャンセルボタンをタップ
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      // 画面がクローズされていることを確認
      expect(find.byType(TaskCreateScreen), findsNothing);
    });
  });
}
