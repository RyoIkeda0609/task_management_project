import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

/// シンプルな Fake MilestoneRepository 実装
class FakeMilestoneRepository implements MilestoneRepository {
  final Map<String, Milestone> _milestones = {};

  void addMilestone(Milestone milestone) {
    _milestones[milestone.itemId.value] = milestone;
  }

  @override
  Future<List<Milestone>> getAllMilestones() async {
    return _milestones.values.toList();
  }

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    return _milestones[id];
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async {
    return _milestones.values.where((m) => m.goalId.value == goalId).toList();
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async {
    _milestones[milestone.itemId.value] = milestone;
  }

  @override
  Future<void> deleteMilestone(String id) async {
    _milestones.remove(id);
  }

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async {
    _milestones.removeWhere((_, m) => m.goalId.value == goalId);
  }

  @override
  Future<int> getMilestoneCount() async {
    return _milestones.length;
  }
}

/// シンプルな Fake TaskRepository 実装
class FakeTaskRepository implements TaskRepository {
  final Map<String, Task> _tasks = {};

  void addTask(Task task) {
    _tasks[task.itemId.value] = task;
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
    return _tasks.values
        .where((t) => t.milestoneId.value == milestoneId)
        .toList();
  }

  @override
  Future<void> saveTask(Task task) async {
    _tasks[task.itemId.value] = task;
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
  group('GoalCompletionService', () {
    late FakeMilestoneRepository fakeMilestoneRepository;
    late FakeTaskRepository fakeTaskRepository;
    late GoalCompletionService goalCompletionService;

    setUp(() {
      fakeMilestoneRepository = FakeMilestoneRepository();
      fakeTaskRepository = FakeTaskRepository();
      goalCompletionService = GoalCompletionService(
        fakeMilestoneRepository,
        fakeTaskRepository,
      );
    });

    group('isGoalCompleted', () {
      test('ゴールにマイルストーンが存在しない場合は false を返す', () async {
        // Arrange
        const goalId = 'goal-1';

        // Act
        final result = await goalCompletionService.isGoalCompleted(goalId);

        // Assert
        expect(result, false);
      });

      test('すべてのマイルストーンのすべてのタスクが完了している場合は true を返す', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';
        const milestone2Id = 'milestone-2';

        final milestone1 = Milestone(
          itemId: ItemId(milestone1Id),
          goalId: ItemId(goalId),
          title: ItemTitle('マイルストーン1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        );
        final milestone2 = Milestone(
          itemId: ItemId(milestone2Id),
          goalId: ItemId(goalId),
          title: ItemTitle('マイルストーン2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);
        fakeMilestoneRepository.addMilestone(milestone2);

        final task1 = Task(
          itemId: ItemId('task-1'),
          milestoneId: ItemId(milestone1Id),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          itemId: ItemId('task-2'),
          milestoneId: ItemId(milestone2Id),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await goalCompletionService.isGoalCompleted(goalId);

        // Assert
        expect(result, true);
      });

      test('一部のマイルストーンが未完了の場合は false を返す', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';
        const milestone2Id = 'milestone-2';

        final milestone1 = Milestone(
          itemId: ItemId(milestone1Id),
          goalId: ItemId(goalId),
          title: ItemTitle('マイルストーン1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        );
        final milestone2 = Milestone(
          itemId: ItemId(milestone2Id),
          goalId: ItemId(goalId),
          title: ItemTitle('マイルストーン2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);
        fakeMilestoneRepository.addMilestone(milestone2);

        final task1 = Task(
          itemId: ItemId('task-1'),
          milestoneId: ItemId(milestone1Id),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          itemId: ItemId('task-2'),
          milestoneId: ItemId(milestone2Id),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDoing),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await goalCompletionService.isGoalCompleted(goalId);

        // Assert
        expect(result, false);
      });

      test('タスクがないマイルストーンは完了していないと判定する', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';

        final milestone1 = Milestone(
          itemId: ItemId(milestone1Id),
          goalId: ItemId(goalId),
          title: ItemTitle('マイルストーン1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);

        // Act
        final result = await goalCompletionService.isGoalCompleted(goalId);

        // Assert
        expect(result, false);
      });

      test('複数のゴールから指定した ID のゴールのみマイルストーンを確認できる', () async {
        // Arrange
        const goal1Id = 'goal-1';
        const goal2Id = 'goal-2';
        const milestone1Id = 'milestone-1';
        const milestone2Id = 'milestone-2';

        final milestone1 = Milestone(
          itemId: ItemId(milestone1Id),
          goalId: ItemId(goal1Id),
          title: ItemTitle('マイルストーン1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        );
        final milestone2 = Milestone(
          itemId: ItemId(milestone2Id),
          goalId: ItemId(goal2Id),
          title: ItemTitle('マイルストーン2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);
        fakeMilestoneRepository.addMilestone(milestone2);

        final task1 = Task(
          itemId: ItemId('task-1'),
          milestoneId: ItemId(milestone1Id),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        fakeTaskRepository.addTask(task1);

        // Act
        final result1 = await goalCompletionService.isGoalCompleted(goal1Id);
        final result2 = await goalCompletionService.isGoalCompleted(goal2Id);

        // Assert
        expect(result1, true);
        expect(result2, false);
      });
    });

    group('calculateGoalProgress', () {
      test('ゴールにマイルストーンが存在しない場合は 0% を返す', () async {
        // Arrange
        const goalId = 'goal-1';

        // Act
        final result = await goalCompletionService.calculateGoalProgress(
          goalId,
        );

        // Assert
        expect(result.value, 0);
      });

      test('すべてのマイルストーンが完了している場合は 100% を返す', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';
        const milestone2Id = 'milestone-2';

        final milestone1 = Milestone(
          id: MilestoneId(milestone1Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン1'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        final milestone2 = Milestone(
          id: MilestoneId(milestone2Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン2'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);
        fakeMilestoneRepository.addMilestone(milestone2);

        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestone1Id,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestone2Id,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await goalCompletionService.calculateGoalProgress(
          goalId,
        );

        // Assert
        expect(result.value, 100);
      });

      test('マイルストーンの平均進捗を計算して返す', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';
        const milestone2Id = 'milestone-2';

        final milestone1 = Milestone(
          id: MilestoneId(milestone1Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン1'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        final milestone2 = Milestone(
          id: MilestoneId(milestone2Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン2'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);
        fakeMilestoneRepository.addMilestone(milestone2);

        // milestone1: 100% (タスク1 Done)
        // milestone2: 50% (タスク2 Doing)
        // 平均: (100 + 50) / 2 = 75%
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestone1Id,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestone2Id,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDoing),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);

        // Act
        final result = await goalCompletionService.calculateGoalProgress(
          goalId,
        );

        // Assert
        expect(result.value, 75);
      });

      test('空のマイルストーンの場合は 0% を返す', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';

        final milestone1 = Milestone(
          id: MilestoneId(milestone1Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン1'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);

        // Act
        final result = await goalCompletionService.calculateGoalProgress(
          goalId,
        );

        // Assert
        expect(result.value, 0);
      });

      test('単一マイルストーンの進捗をそのまま返す', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';

        final milestone1 = Milestone(
          id: MilestoneId(milestone1Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン1'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);

        // milestone1: 50% (タスク1 Doing)
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestone1Id,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDoing),
        );
        fakeTaskRepository.addTask(task1);

        // Act
        final result = await goalCompletionService.calculateGoalProgress(
          goalId,
        );

        // Assert
        expect(result.value, 50);
      });

      test('複数マイルストーンの場合、異なる進捗を正しく集約する', () async {
        // Arrange
        const goalId = 'goal-1';
        const milestone1Id = 'milestone-1';
        const milestone2Id = 'milestone-2';
        const milestone3Id = 'milestone-3';

        final milestone1 = Milestone(
          id: MilestoneId(milestone1Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン1'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        final milestone2 = Milestone(
          id: MilestoneId(milestone2Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン2'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        final milestone3 = Milestone(
          id: MilestoneId(milestone3Id),
          goalId: goalId,
          title: MilestoneTitle('マイルストーン3'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        );
        fakeMilestoneRepository.addMilestone(milestone1);
        fakeMilestoneRepository.addMilestone(milestone2);
        fakeMilestoneRepository.addMilestone(milestone3);

        // milestone1: 100% (タスク1 Done)
        // milestone2: 50% (タスク2 Doing)
        // milestone3: 0% (タスク3 Todo)
        // 平均: (100 + 50 + 0) / 3 = 50%
        final task1 = Task(
          id: TaskId('task-1'),
          milestoneId: milestone1Id,
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDone),
        );
        final task2 = Task(
          id: TaskId('task-2'),
          milestoneId: milestone2Id,
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusDoing),
        );
        final task3 = Task(
          id: TaskId('task-3'),
          milestoneId: milestone3Id,
          title: TaskTitle('タスク3'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: TaskStatus(TaskStatus.statusTodo),
        );
        fakeTaskRepository.addTask(task1);
        fakeTaskRepository.addTask(task2);
        fakeTaskRepository.addTask(task3);

        // Act
        final result = await goalCompletionService.calculateGoalProgress(
          goalId,
        );

        // Assert
        expect(result.value, 50);
      });
    });
  });
}
