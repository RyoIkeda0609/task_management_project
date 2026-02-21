import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/progress/calculate_progress_use_case.dart';
import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';







import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<List<Milestone>> getAllMilestones() async => _milestones;

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      return _milestones.firstWhere((m) => m.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByItemId(String goalId) async {
    return _milestones.where((m) => m.goalId == goalId).toList();
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.itemId.value == id);

  @override
  Future<void> deleteMilestonesByItemId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId == goalId);

  @override
  Future<int> getMilestoneCount() async => _milestones.length;
}

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
  Future<List<Task>> getTasksByItemId(String milestoneId) async {
    return _tasks.where((t) => t.milestoneId == milestoneId).toList();
  }

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.itemId.value == id);

  @override
  Future<void> deleteTasksByItemId(String milestoneId) async =>
      _tasks.removeWhere((t) => t.milestoneId == milestoneId);

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

/// MockGoalCompletionService - Service の Mock 実装
class MockGoalCompletionService implements GoalCompletionService {
  final MockMilestoneRepository milestoneRepository;
  final MockTaskRepository taskRepository;

  MockGoalCompletionService(this.milestoneRepository, this.taskRepository);

  @override
  Future<bool> isGoalCompleted(String goalId) async {
    final milestones = await milestoneRepository.getMilestonesByItemId(goalId);
    if (milestones.isEmpty) return false;

    int completedCount = 0;
    for (final milestone in milestones) {
      final tasks = await taskRepository.getTasksByItemId(
        milestone.itemId.value,
      );
      if (tasks.isNotEmpty) {
        final allTasksDone = tasks.every((task) => task.status.isDone);
        if (allTasksDone) {
          completedCount++;
        }
      }
    }
    return completedCount == milestones.length;
  }

  @override
  Future<Progress> calculateGoalProgress(String goalId) async {
    final milestones = await milestoneRepository.getMilestonesByItemId(goalId);

    if (milestones.isEmpty) {
      return Progress(0);
    }

    int totalProgress = 0;
    for (final milestone in milestones) {
      final tasks = await taskRepository.getTasksByItemId(
        milestone.itemId.value,
      );

      if (tasks.isEmpty) {
        continue;
      }

      final taskProgresses = tasks
          .map((task) => task.getProgress().value)
          .toList();
      final avg =
          taskProgresses.fold<int>(0, (sum, p) => sum + p) ~/ tasks.length;
      totalProgress += avg;
    }

    final goalProgress = totalProgress ~/ milestones.length;
    return Progress(goalProgress);
  }
}

/// MockMilestoneCompletionService - Service の Mock 実装
class MockMilestoneCompletionService implements MilestoneCompletionService {
  final MockTaskRepository taskRepository;

  MockMilestoneCompletionService(this.taskRepository);

  @override
  Future<bool> isMilestoneCompleted(String milestoneId) async {
    final tasks = await taskRepository.getTasksByItemId(milestoneId);

    if (tasks.isEmpty) {
      return false;
    }

    final allTasksDone = tasks.every((task) => task.status.isDone);
    return allTasksDone;
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    final tasks = await taskRepository.getTasksByItemId(milestoneId);

    if (tasks.isEmpty) {
      return Progress(0);
    }

    final totalProgress = tasks.fold<int>(
      0,
      (sum, task) => sum + task.getProgress().value,
    );
    final average = totalProgress ~/ tasks.length;
    return Progress(average);
  }
}

void main() {
  group('CalculateProgressUseCase', () {
    late CalculateProgressUseCase useCase;
    late MockMilestoneRepository mockMilestoneRepository;
    late MockTaskRepository mockTaskRepository;
    late MockGoalCompletionService mockGoalCompletionService;
    late MockMilestoneCompletionService mockMilestoneCompletionService;

    setUp(() {
      mockMilestoneRepository = MockMilestoneRepository();
      mockTaskRepository = MockTaskRepository();
      mockGoalCompletionService = MockGoalCompletionService(
        mockMilestoneRepository,
        mockTaskRepository,
      );
      mockMilestoneCompletionService = MockMilestoneCompletionService(
        mockTaskRepository,
      );
      useCase = CalculateProgressUseCaseImpl(
        mockGoalCompletionService,
        mockMilestoneCompletionService,
      );
    });

    group('Goal進捗計算', () {
      test('タスクなしのゴールは 0% の進捗', () async {
        // Arrange: Milestone がない Goal の進捗を計算
        // Act & Assert: 0% を返す
        final progress = await useCase.calculateGoalProgress('goal-without-ms');

        expect(progress.value, 0);
        expect(progress.isNotStarted, true);
      });

      test('全タスク完了のゴールは 100% の進捗', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS'),
          deadline: ItemDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: ItemId('\'),
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final task = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.itemId.value,
        );
        await mockTaskRepository.saveTask(task);

        // Act
        final progress = await useCase.calculateGoalProgress('goal-123');

        // Assert
        expect(progress.value, 100);
        expect(progress.isCompleted, true);
      });

      test('複数マイルストーンの平均進捗が計算される', () async {
        // Arrange
        // MS1: タスク1個完了（100%）
        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1'),
          deadline: ItemDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: ItemId('\'),
        );
        await mockMilestoneRepository.saveMilestone(ms1);

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: ms1.itemId.value,
        );
        await mockTaskRepository.saveTask(task1);

        // MS2: タスク2個（1個Done=100%, 1個Todo=0%, 平均50%）
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2'),
          deadline: ItemDeadline(
            DateTime.now().add(const Duration(days: 200)),
          ),
          goalId: ItemId('\'),
        );
        await mockMilestoneRepository.saveMilestone(ms2);

        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2-1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: ms2.itemId.value,
        );
        final task3 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2-2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: ms2.itemId.value,
        );
        await mockTaskRepository.saveTask(task2);
        await mockTaskRepository.saveTask(task3);

        // Act
        final progress = await useCase.calculateGoalProgress('goal-456');

        // Assert
        // MS1:100%, MS2:50% => 平均75%
        expect(progress.value, 75);
      });
    });

    group('Milestone進捗計算', () {
      test('タスクなしのマイルストーンは 0% の進捗', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS'),
          deadline: ItemDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: ItemId('\'),
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        // Act
        final progress = await useCase.calculateMilestoneProgress(
          milestone.itemId.value,
        );

        // Assert
        expect(progress.value, 0);
      });

      test('全タスク完了のマイルストーンは 100% の進捗', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS'),
          deadline: ItemDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: ItemId('\'),
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.itemId.value,
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.itemId.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // Act
        final progress = await useCase.calculateMilestoneProgress(
          milestone.itemId.value,
        );

        // Assert
        expect(progress.value, 100);
      });

      test('複数タスクの平均進捗が計算される', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS'),
          deadline: ItemDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: ItemId('\'),
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        // Task1: Done(100%), Task2: Doing(50%), Task3: Todo(0%) => 平均50%
        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.itemId.value,
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.doing(),
          milestoneId: milestone.itemId.value,
        );
        final task3 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク3'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: milestone.itemId.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);
        await mockTaskRepository.saveTask(task3);

        // Act
        final progress = await useCase.calculateMilestoneProgress(
          milestone.itemId.value,
        );

        // Assert
        expect(progress.value, 50); // (100 + 50 + 0) / 3 = 50
      });
    });

    group('エラーハンドリング', () {
      test('空のゴール ID でエラー', () async {
        expect(
          () => useCase.calculateGoalProgress(''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('空のマイルストーン ID でエラー', () async {
        expect(
          () => useCase.calculateMilestoneProgress(''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('存在しないゴールの進捗計算は 0%', () async {
        // Service implementation では Repository を通さないため、
        // 存在しないゴールでも Milestone がない扱いで 0% を返す
        final progress = await useCase.calculateGoalProgress(
          'non-existent-goal',
        );
        expect(progress.value, 0);
      });

      test('存在しないマイルストーンの進捗計算は 0%', () async {
        // Service implementation では Task がない扱いで 0% を返す
        final progress = await useCase.calculateMilestoneProgress(
          'non-existent-milestone',
        );
        expect(progress.value, 0);
      });
    });
  });
}



