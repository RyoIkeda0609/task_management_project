import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/get_tasks_by_milestone_id_use_case.dart';
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
  Future<void> saveTask(Task task) async => _tasks.add(task);

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
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明1'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: milestoneId,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明2'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 14))),
          status: TaskStatus.doing(),
          milestoneId: milestoneId,
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        final result = await useCase(milestoneId);

        // Assert
        expect(result.length, 2);
        expect(
          result.map((t) => t.id.value),
          containsAll([task1.id.value, task2.id.value]),
        );
        expect(result.every((t) => t.milestoneId == milestoneId), true);
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
          id: TaskId.generate(),
          title: TaskTitle('MS1タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: msId1,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('MS2タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: msId2,
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        final result1 = await useCase(msId1);
        final result2 = await useCase(msId2);

        // Assert
        expect(result1.length, 1);
        expect(result2.length, 1);
        expect(result1.first.id.value, task1.id.value);
        expect(result2.first.id.value, task2.id.value);
      });

      test('複数タスクを持つマイルストーンをすべて取得できること', () async {
        // Arrange
        const milestoneId = 'milestone-multi-task';
        final tasks = <Task>[];
        for (int i = 1; i <= 5; i++) {
          tasks.add(
            Task(
              id: TaskId.generate(),
              title: TaskTitle('タスク$i'),
              description: TaskDescription('説明'),
              deadline: TaskDeadline(DateTime.now().add(Duration(days: 7 * i))),
              status: TaskStatus.todo(),
              milestoneId: milestoneId,
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
          result.map((t) => t.id.value),
          containsAll(tasks.map((t) => t.id.value)),
        );
      });

      test('複数ステータスのタスクをすべて取得できること', () async {
        // Arrange
        const milestoneId = 'milestone-123';
        final todoTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('未開始'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: milestoneId,
        );
        final doingTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('進行中'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.doing(),
          milestoneId: milestoneId,
        );
        final doneTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('完了'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.done(),
          milestoneId: milestoneId,
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
