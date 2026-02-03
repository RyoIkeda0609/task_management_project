import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/delete_task_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.where((t) => t.milestoneId == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async {
    _tasks.removeWhere((t) => t.id.value == task.id.value);
    _tasks.add(task);
  }

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.id.value == id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
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
          id: TaskId.generate(),
          title: TaskTitle('削除対象タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.id.value);

        // Assert
        final deleted = await mockRepository.getTaskById(task.id.value);
        expect(deleted, isNull);
      });

      test('複数タスクの削除が独立していること', () async {
        // Arrange
        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明1'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明2'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 14))),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-123',
        );
        final task3 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク3'),
          description: TaskDescription('説明3'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 21))),
          status: TaskStatus.done(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);
        await mockRepository.saveTask(task3);

        // Act
        await useCase(task1.id.value);

        // Assert
        expect(await mockRepository.getTaskById(task2.id.value), isNotNull);
        expect(await mockRepository.getTaskById(task3.id.value), isNotNull);
        expect(await mockRepository.getTaskById(task1.id.value), isNull);
      });

      test('Todo ステータスのタスクを削除できること', () async {
        // Arrange
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.id.value);

        // Assert
        expect(await mockRepository.getTaskById(task.id.value), isNull);
      });

      test('Doing ステータスのタスクを削除できること', () async {
        // Arrange
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.id.value);

        // Assert
        expect(await mockRepository.getTaskById(task.id.value), isNull);
      });

      test('Done ステータスのタスクを削除できること', () async {
        // Arrange
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.done(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        // Act
        await useCase(task.id.value);

        // Assert
        expect(await mockRepository.getTaskById(task.id.value), isNull);
      });

      test('異なるマイルストーン下のタスク削除が独立していること', () async {
        // Arrange
        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('マイルストーン1のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('マイルストーン2のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-2',
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        await useCase(task1.id.value);

        // Assert
        expect(await mockRepository.getTaskById(task2.id.value), isNotNull);
        expect(await mockRepository.getTaskById(task1.id.value), isNull);
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
