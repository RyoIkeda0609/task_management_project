import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('GetTasksGroupedByStatusUseCase', () {
    late GetTasksGroupedByStatusUseCase useCase;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      useCase = GetTasksGroupedByStatusUseCaseImpl();
    });

    Task createTask(String id, TaskStatus status) {
      return Task(
        itemId: ItemId(id),
        title: ItemTitle('Task $id'),
        description: ItemDescription(''),
        deadline: ItemDeadline(tomorrow),
        status: status,
        milestoneId: ItemId('ms-1'),
      );
    }

    test('空のリストの場合、すべてのグループが空であること', () async {
      final result = await useCase.call([]);

      expect(result.todoTasks, isEmpty);
      expect(result.doingTasks, isEmpty);
      expect(result.doneTasks, isEmpty);
      expect(result.total, 0);
    });

    test('タスクがステータス別に正しくグループ化されること', () async {
      final tasks = [
        createTask('t1', TaskStatus.todo()),
        createTask('t2', TaskStatus.doing()),
        createTask('t3', TaskStatus.done()),
        createTask('t4', TaskStatus.todo()),
      ];

      final result = await useCase.call(tasks);

      expect(result.todoTasks.length, 2);
      expect(result.doingTasks.length, 1);
      expect(result.doneTasks.length, 1);
      expect(result.total, 4);
    });

    test('completedCount が Done タスク数と一致すること', () async {
      final tasks = [
        createTask('t1', TaskStatus.done()),
        createTask('t2', TaskStatus.done()),
        createTask('t3', TaskStatus.todo()),
      ];

      final result = await useCase.call(tasks);

      expect(result.completedCount, 2);
    });

    test('completionPercentage が正しく計算されること', () async {
      final tasks = [
        createTask('t1', TaskStatus.done()),
        createTask('t2', TaskStatus.todo()),
      ];

      final result = await useCase.call(tasks);

      expect(result.completionPercentage, 50);
    });

    test('タスクがない場合 completionPercentage が 0 であること', () async {
      final result = await useCase.call([]);

      expect(result.completionPercentage, 0);
    });

    test('すべて Done の場合 completionPercentage が 100 であること', () async {
      final tasks = [
        createTask('t1', TaskStatus.done()),
        createTask('t2', TaskStatus.done()),
        createTask('t3', TaskStatus.done()),
      ];

      final result = await useCase.call(tasks);

      expect(result.completionPercentage, 100);
    });

    test('allTasks が全タスクを含むこと', () async {
      final tasks = [
        createTask('t1', TaskStatus.todo()),
        createTask('t2', TaskStatus.doing()),
        createTask('t3', TaskStatus.done()),
      ];

      final result = await useCase.call(tasks);

      expect(result.allTasks.length, 3);
    });

    test('すべて同じステータスの場合に正しくグループ化されること', () async {
      final tasks = [
        createTask('t1', TaskStatus.doing()),
        createTask('t2', TaskStatus.doing()),
      ];

      final result = await useCase.call(tasks);

      expect(result.todoTasks, isEmpty);
      expect(result.doingTasks.length, 2);
      expect(result.doneTasks, isEmpty);
    });
  });
}
