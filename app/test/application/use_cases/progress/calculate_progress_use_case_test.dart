import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/progress/calculate_progress_use_case.dart';
import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<List<Milestone>> getAllMilestones() async => _milestones;

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      return _milestones.firstWhere((m) => m.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async {
    return _milestones.where((m) => m.goalId == goalId).toList();
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.id.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
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
      return _tasks.firstWhere((t) => t.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async {
    return _tasks.where((t) => t.milestoneId == milestoneId).toList();
  }

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

/// MockGoalCompletionService - Service の Mock 実装
class MockGoalCompletionService implements GoalCompletionService {
  final MockMilestoneRepository milestoneRepository;
  final MockTaskRepository taskRepository;

  MockGoalCompletionService(this.milestoneRepository, this.taskRepository);

  @override
  Future<bool> isGoalCompleted(String goalId) async {
    final milestones = await milestoneRepository.getMilestonesByGoalId(goalId);
    if (milestones.isEmpty) return false;

    int completedCount = 0;
    for (final milestone in milestones) {
      final tasks = await taskRepository.getTasksByMilestoneId(
        milestone.id.value,
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
    final milestones = await milestoneRepository.getMilestonesByGoalId(goalId);

    if (milestones.isEmpty) {
      return Progress(0);
    }

    int totalProgress = 0;
    for (final milestone in milestones) {
      final tasks = await taskRepository.getTasksByMilestoneId(
        milestone.id.value,
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
    final tasks = await taskRepository.getTasksByMilestoneId(milestoneId);

    if (tasks.isEmpty) {
      return false;
    }

    final allTasksDone = tasks.every((task) => task.status.isDone);
    return allTasksDone;
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    final tasks = await taskRepository.getTasksByMilestoneId(milestoneId);

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
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: 'goal-123',
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.id.value,
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
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS1'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: 'goal-456',
        );
        await mockMilestoneRepository.saveMilestone(ms1);

        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: ms1.id.value,
        );
        await mockTaskRepository.saveTask(task1);

        // MS2: タスク2個（1個Done=100%, 1個Todo=0%, 平均50%）
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS2'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 200)),
          ),
          goalId: 'goal-456',
        );
        await mockMilestoneRepository.saveMilestone(ms2);

        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2-1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: ms2.id.value,
        );
        final task3 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2-2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: ms2.id.value,
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
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: 'goal-123',
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        // Act
        final progress = await useCase.calculateMilestoneProgress(
          milestone.id.value,
        );

        // Assert
        expect(progress.value, 0);
      });

      test('全タスク完了のマイルストーンは 100% の進捗', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: 'goal-123',
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.id.value,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.id.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // Act
        final progress = await useCase.calculateMilestoneProgress(
          milestone.id.value,
        );

        // Assert
        expect(progress.value, 100);
      });

      test('複数タスクの平均進捗が計算される', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: 'goal-123',
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        // Task1: Done(100%), Task2: Doing(50%), Task3: Todo(0%) => 平均50%
        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.id.value,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.doing(),
          milestoneId: milestone.id.value,
        );
        final task3 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク3'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: milestone.id.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);
        await mockTaskRepository.saveTask(task3);

        // Act
        final progress = await useCase.calculateMilestoneProgress(
          milestone.id.value,
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
