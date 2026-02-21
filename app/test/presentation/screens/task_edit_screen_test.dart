import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/task/task_edit/task_edit_page.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/state_management/providers/app_providers.dart';

class FakeTaskRepository implements TaskRepository {
  @override
  Future<void> saveTask(Task task) async {}

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<Task?> getTaskById(String id) async => Task(
    id: TaskId(id),
    title: TaskTitle('テスト タスク'),
    description: TaskDescription('これはテストタスクです'),
    deadline: TaskDeadline(DateTime(2026, 3, 1)),
    status: TaskStatus.todo(),
    milestoneId: 'milestone-1',
  );

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async => [];

  @override
  Future<void> deleteTask(String taskId) async {}

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async {}

  @override
  Future<int> getTaskCount() async => 0;
}

void main() {
  group('TaskEditPage Tests', () {
    testWidgets('displays task edit form', (WidgetTester tester) async {
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
          child: const MaterialApp(home: TaskEditPage(taskId: 'test-task-1')),
        ),
      );

      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('タスクを編集'), findsWidgets);
      expect(find.text('テスト タスク'), findsOneWidget);
      expect(find.text('これはテストタスクです'), findsOneWidget);
    });

    testWidgets('shows error when task not found', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            taskDetailProvider(
              'nonexistent-task',
            ).overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: TaskEditPage(taskId: 'nonexistent-task'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('タスクが見つかりません'), findsOneWidget);
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
            taskDetailProvider('test-task-1').overrideWith(
              (ref) async => await Future.delayed(
                const Duration(seconds: 1),
                () => Task(
                  id: TaskId('test-task-1'),
                  title: TaskTitle('テスト タスク'),
                  description: TaskDescription('これはテストタスクです'),
                  deadline: TaskDeadline(DateTime(2026, 3, 1)),
                  status: TaskStatus.todo(),
                  milestoneId: 'milestone-1',
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: TaskEditPage(taskId: 'test-task-1')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
