import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
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
  group('MilestoneCompletionService', () {
    late FakeTaskRepository fakeTaskRepository;
    late MilestoneCompletionService milestoneCompletionService;

    setUp(() {
      fakeTaskRepository = FakeTaskRepository();
      milestoneCompletionService = MilestoneCompletionService(
        fakeTaskRepository,
      );
    });

    group('isMilestoneCompleted', () {
      test('マイルストーンのすべてのタスクが完了している場合は true を返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await milestoneCompletionService.isMilestoneCompleted(
          milestoneId,
        );

        // Assert
        expect(result, true);
      });

      test('マイルストーンにタスクがない場合は false を返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';

        // Act
        final result = await milestoneCompletionService.isMilestoneCompleted(
          milestoneId,
        );

        // Assert
        expect(result, false);
      });

      test('マイルストーン内の一部のタスクが未完了の場合は false を返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDoing),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await milestoneCompletionService.isMilestoneCompleted(
          milestoneId,
        );

        // Assert
        expect(result, false);
      });

      test('すべてのタスクが Todo ステータスの場合は false を返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusTodo),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusTodo),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await milestoneCompletionService.isMilestoneCompleted(
          milestoneId,
        );

        // Assert
        expect(result, false);
      });
    });

    group('calculateMilestoneProgress', () {
      test('タスクがない場合は 0% を返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';

        // Act
        final result = await milestoneCompletionService
            .calculateMilestoneProgress(milestoneId);

        // Assert
        expect(result.value, 0);
      });

      test('タスクの平均進捗を計算して返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDoing),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await milestoneCompletionService
            .calculateMilestoneProgress(milestoneId);

        // Assert
        // (100 + 50) / 2 = 75
        expect(result.value, 75);
      });

      test('すべてのタスクが完了している場合は 100% を返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await milestoneCompletionService
            .calculateMilestoneProgress(milestoneId);

        // Assert
        expect(result.value, 100);
      });

      test('1つのタスク 0% の場合は 0% を返す', () async {
        // Arrange
        const milestoneId = 'milestone-1';
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestoneId,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusTodo),
        );
        fakeTaskRepository.addTask(task1);

        // Act
        final result = await milestoneCompletionService
            .calculateMilestoneProgress(milestoneId);

        // Assert
        expect(result.value, 0);
      });
    });
  });
}
