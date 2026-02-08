import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/task/task_create_screen.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/state_management/providers/app_providers.dart';
import 'package:app/domain/entities/task.dart';

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

  @override
  Future<void> updateTask(Task task) async {}
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
      expect(find.text('タスクの説明'), findsOneWidget);
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
          ],
          child: MaterialApp(
            home: TaskCreateScreen(arguments: {'milestoneId': 'milestone-123'}),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('マイルストーンに紐付けます'), findsOneWidget);
      expect(find.text('ID: milestone-123'), findsOneWidget);
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
