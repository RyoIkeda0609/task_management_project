import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/task/task_detail_screen.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/state_management/providers/app_providers.dart';

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

void main() {
  group('TaskDetailScreen', () {
    testWidgets('displays task details properly', (WidgetTester tester) async {
      final testTask = Task(
        id: TaskId('test-task-1'),
        title: TaskTitle('テスト タスク'),
        description: TaskDescription('これはテストタスクです'),
        deadline: TaskDeadline(DateTime(2026, 3, 1)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            taskDetailProvider(
              'test-task-1',
            ).overrideWith((ref) async => testTask),
          ],
          child: MaterialApp(home: TaskDetailScreen(taskId: 'test-task-1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('テスト タスク'), findsOneWidget);
      expect(find.text('これはテストタスクです'), findsOneWidget);
      expect(find.text('未完了'), findsWidgets);
    });

    testWidgets('displays error message when task is not found', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            taskDetailProvider('invalid-id').overrideWith((ref) async => null),
          ],
          child: MaterialApp(home: TaskDetailScreen(taskId: 'invalid-id')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('タスクが見つかりません'), findsOneWidget);
    });

    testWidgets('updates task status to done', (WidgetTester tester) async {
      final testTask = Task(
        id: TaskId('test-task-1'),
        title: TaskTitle('テスト タスク'),
        description: TaskDescription('これはテストタスクです'),
        deadline: TaskDeadline(DateTime(2026, 3, 1)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            taskDetailProvider(
              'test-task-1',
            ).overrideWith((ref) async => testTask),
          ],
          child: MaterialApp(home: TaskDetailScreen(taskId: 'test-task-1')),
        ),
      );

      await tester.pumpAndSettle();

      // 「完了にする」ボタンをタップ
      await tester.tap(find.text('完了にする'));
      await tester.pumpAndSettle();
    });

    testWidgets('displays status icons correctly', (WidgetTester tester) async {
      final todoTask = Task(
        id: TaskId('test-task-1'),
        title: TaskTitle('未完了タスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 3, 1)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            taskDetailProvider(
              'test-task-1',
            ).overrideWith((ref) async => todoTask),
          ],
          child: MaterialApp(home: TaskDetailScreen(taskId: 'test-task-1')),
        ),
      );

      await tester.pumpAndSettle();

      // ステータステキストが正しく表示されているか確認
      expect(find.text('未完了'), findsWidgets);
    });

    testWidgets('shows all status update buttons', (WidgetTester tester) async {
      final testTask = Task(
        id: TaskId('test-task-1'),
        title: TaskTitle('テスト タスク'),
        description: TaskDescription('これはテストタスクです'),
        deadline: TaskDeadline(DateTime(2026, 3, 1)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            taskDetailProvider(
              'test-task-1',
            ).overrideWith((ref) async => testTask),
          ],
          child: MaterialApp(home: TaskDetailScreen(taskId: 'test-task-1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('未完了にする'), findsOneWidget);
      expect(find.text('進行中にする'), findsOneWidget);
      expect(find.text('完了にする'), findsOneWidget);
    });
  });
}
