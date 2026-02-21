import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/delete_task_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';




import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByItemId(String milestoneId) async =>
      _tasks.where((t) => t.milestoneId == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async {
    _tasks.removeWhere((t) => t.itemId.value == task.itemId.value);
    _tasks.add(task);
  }

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.itemId.value == id);

  @override
  Future<void> deleteTasksByItemId(String milestoneId) async =>
      _tasks.removeWhere((t) => t.milestoneId == milestoneId);

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

void main() {
  group('DeleteTaskUseCase', () {
    late DeleteTaskUseCase useCase;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = DeleteTaskUseCaseImpl(mockRepository);
    });

    group('タスク削除', () {
      test('タスクを削除できること', () async {
        // Arrange
        final task = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('削除対象タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: ItemId('\'),
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.itemId.value);

        // Assert
        final deleted = await mockRepository.getTaskById(task.itemId.value);
        expect(deleted, isNull);
      });

      test('複数タスクの削除が独立していること', () async {
        // Arrange
        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明1'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: ItemId('\'),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明2'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 14))),
          status: TaskStatus.doing(),
          milestoneId: ItemId('\'),
        );
        final task3 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク3'),
          description: ItemDescription('説明3'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 21))),
          status: TaskStatus.done(),
          milestoneId: ItemId('\'),
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);
        await mockRepository.saveTask(task3);

        // Act
        await useCase(task1.itemId.value);

        // Assert
        expect(await mockRepository.getTaskById(task2.itemId.value), isNotNull);
        expect(await mockRepository.getTaskById(task3.itemId.value), isNotNull);
        expect(await mockRepository.getTaskById(task1.itemId.value), isNull);
      });

      test('Todo ステータスのタスクを削除できること', () async {
        // Arrange
        final task = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: ItemId('\'),
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.itemId.value);

        // Assert
        expect(await mockRepository.getTaskById(task.itemId.value), isNull);
      });

      test('Doing ステータスのタスクを削除できること', () async {
        // Arrange
        final task = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.doing(),
          milestoneId: ItemId('\'),
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.itemId.value);

        // Assert
        expect(await mockRepository.getTaskById(task.itemId.value), isNull);
      });

      test('Done ステータスのタスクを削除できること', () async {
        // Arrange
        final task = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.done(),
          milestoneId: ItemId('\'),
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.itemId.value);

        // Assert
        expect(await mockRepository.getTaskById(task.itemId.value), isNull);
      });

      test('異なるマイルストーン下のタスク削除が独立していること', () async {
        // Arrange
        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('マイルストーン1のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: ItemId('\'),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('マイルストーン2のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: ItemId('\'),
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        await useCase(task1.itemId.value);

        // Assert
        expect(await mockRepository.getTaskById(task2.itemId.value), isNotNull);
        expect(await mockRepository.getTaskById(task1.itemId.value), isNull);
      });
    });

    group('エラーハンドリング', () {
      test('存在しないタスク ID での削除でエラーが発生すること', () async {
        // Act & Assert
        expect(
          () async => await useCase('non-existent-id'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('空のタスク ID でエラーが発生すること', () async {
        // Act & Assert
        expect(() async => await useCase(''), throwsA(isA<ArgumentError>()));
      });
    });
  });
}




