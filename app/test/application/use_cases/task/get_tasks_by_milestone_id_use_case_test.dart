import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/get_tasks_by_milestone_id_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import '../../../helpers/mock_repositories.dart';

void main() {
  group('GetTasksByMilestoneIdUseCase', () {
    late GetTasksByMilestoneIdUseCase useCase;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = GetTasksByMilestoneIdUseCaseImpl(mockRepository);
    });

    group('タスク取得', () {
      test('マイルストーン ID でタスクを取得できること', () async {
        // Arrange
        const milestoneId = 'milestone-123';
        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明1'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId(milestoneId),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明2'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 14))),
          status: TaskStatus.doing,
          milestoneId: ItemId(milestoneId),
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        final result = await useCase(milestoneId);

        // Assert
        expect(result.length, 2);
        expect(
          result.map((t) => t.itemId.value),
          containsAll([task1.itemId.value, task2.itemId.value]),
        );
        expect(result.every((t) => t.milestoneId.value == milestoneId), true);
      });

      test('タスクなしのマイルストーン ID で空リストが返されること', () async {
        // Arrange
        const milestoneId = 'milestone-no-tasks';

        // Act
        final result = await useCase(milestoneId);

        // Assert
        expect(result, isEmpty);
      });

      test('複数マイルストーン間のタスク独立性を確認できること', () async {
        // Arrange
        const msId1 = 'milestone-1';
        const msId2 = 'milestone-2';

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId(msId1),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId(msId2),
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        final result1 = await useCase(msId1);
        final result2 = await useCase(msId2);

        // Assert
        expect(result1.length, 1);
        expect(result2.length, 1);
        expect(result1.first.itemId.value, task1.itemId.value);
        expect(result2.first.itemId.value, task2.itemId.value);
      });

      test('複数タスクを持つマイルストーンをすべて取得できること', () async {
        // Arrange
        const milestoneId = 'milestone-multi-task';
        final tasks = <Task>[];
        for (int i = 1; i <= 5; i++) {
          tasks.add(
            Task(
              itemId: ItemId.generate(),
              title: ItemTitle('タスク$i'),
              description: ItemDescription('説明'),
              deadline: ItemDeadline(DateTime.now().add(Duration(days: 7 * i))),
              status: TaskStatus.todo,
              milestoneId: ItemId(milestoneId),
            ),
          );
        }
        for (final task in tasks) {
          await mockRepository.saveTask(task);
        }

        // Act
        final result = await useCase(milestoneId);

        // Assert
        expect(result.length, 5);
        expect(
          result.map((t) => t.itemId.value),
          containsAll(tasks.map((t) => t.itemId.value)),
        );
      });

      test('複数ステータスのタスクをすべて取得できること', () async {
        // Arrange
        const milestoneId = 'milestone-123';
        final todoTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('未開始'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId(milestoneId),
        );
        final doingTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('進行中'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.doing,
          milestoneId: ItemId(milestoneId),
        );
        final doneTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('完了'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.done,
          milestoneId: ItemId(milestoneId),
        );
        await mockRepository.saveTask(todoTask);
        await mockRepository.saveTask(doingTask);
        await mockRepository.saveTask(doneTask);

        // Act
        final result = await useCase(milestoneId);

        // Assert
        expect(result.length, 3);
        expect(result.where((t) => t.status.isTodo).length, 1);
        expect(result.where((t) => t.status.isDoing).length, 1);
        expect(result.where((t) => t.status.isDone).length, 1);
      });
    });

    group('エラーハンドリング', () {
      test('空のマイルストーン ID でエラーが発生すること', () async {
        // Act & Assert
        expect(() => useCase(''), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
