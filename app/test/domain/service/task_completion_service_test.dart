import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/task_completion_service.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

/// シンプルな Fake TaskRepository 実装
/// テスト用のインメモリリポジトリ
class FakeTaskRepository implements TaskRepository {
  final Map<String, Task> _tasks = {};

  /// テスト用メソッド：タスクを内部ストレージに追加
  void addTask(Task task) {
    _tasks[task.id.value] = task;
  }

  @override
  Future<List<Task>> getAllTasks() async {
    return _tasks.values.toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return _tasks[id];
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async {
    return _tasks.values.where((t) => t.milestoneId == milestoneId).toList();
  }

  @override
  Future<void> saveTask(Task task) async {
    _tasks[task.id.value] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
  }

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async {
    _tasks.removeWhere((_, task) => task.milestoneId == milestoneId);
  }

  @override
  Future<int> getTaskCount() async {
    return _tasks.length;
  }
}

void main() {
  group('TaskCompletionService', () {
    late FakeTaskRepository fakeTaskRepository;
    late TaskCompletionService taskCompletionService;

    setUp(() {
      fakeTaskRepository = FakeTaskRepository();
      taskCompletionService = TaskCompletionService(fakeTaskRepository);
    });

    group('isTaskCompleted', () {
      test('タスクが完了（Done）している場合は true を返す', () async {
        // Arrange
        const taskId = 'task-1';
        final completedTask = Task(
          id: TaskId(taskId),
          milestoneId: 'milestone-1',
          title: TaskTitle('完了したタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        fakeTaskRepository.addTask(completedTask);

        // Act
        final result = await taskCompletionService.isTaskCompleted(taskId);

        // Assert
        expect(result, true);
      });

      test('タスクが完了していない場合（Doing）は false を返す', () async {
        // Arrange
        const taskId = 'task-1';
        final incompleteTask = Task(
          id: TaskId(taskId),
          milestoneId: 'milestone-1',
          title: TaskTitle('進行中のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDoing),
        );
        fakeTaskRepository.addTask(incompleteTask);

        // Act
        final result = await taskCompletionService.isTaskCompleted(taskId);

        // Assert
        expect(result, false);
      });

      test('タスクが見つからない場合は例外をスローする', () async {
        // Arrange
        const taskId = 'task-999';

        // Act & Assert
        expect(
          () => taskCompletionService.isTaskCompleted(taskId),
          throwsException,
        );
      });

      test('タスクステータスが Todo の場合は false を返す', () async {
        // Arrange
        const taskId = 'task-1';
        final todoTask = Task(
          id: TaskId(taskId),
          milestoneId: 'milestone-1',
          title: TaskTitle('未開始のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusTodo),
        );
        fakeTaskRepository.addTask(todoTask);

        // Act
        final result = await taskCompletionService.isTaskCompleted(taskId);

        // Assert
        expect(result, false);
      });

      test('複数のタスクから指定した ID のタスクのみを確認できる', () async {
        // Arrange
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: 'milestone-1',
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: 'milestone-1',
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusTodo),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result1 = await taskCompletionService.isTaskCompleted('task-1');
        final result2 = await taskCompletionService.isTaskCompleted('task-2');

        // Assert
        expect(result1, true);
        expect(result2, false);
      });

      test('不正な状態値の場合は false を返す', () async {
        // Arrange
        const taskId = 'task-1';
        final taskWithInvalidStatus = Task(
          id: TaskId(taskId),
          milestoneId: 'milestone-1',
          title: TaskTitle('不正な状態のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus('invalid-status'),
        );
        fakeTaskRepository.addTask(taskWithInvalidStatus);

        // Act
        final result = await taskCompletionService.isTaskCompleted(taskId);

        // Assert
        expect(result, false);
      });
    });
  });
}
