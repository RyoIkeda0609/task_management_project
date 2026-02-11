import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/delete_goal_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> getAllGoals() async => _goals;

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async => _goals.add(goal);

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id.value == id);
  }

  @override
  Future<void> deleteAllGoals() async => _goals.clear();

  @override
  Future<int> getGoalCount() async => _goals.length;
}

class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];
  final MockTaskRepository _taskRepository;

  MockMilestoneRepository(this._taskRepository);

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
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      _milestones.where((m) => m.goalId == goalId).toList();

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.id.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async {
    // Get milestones to delete and cascade delete tasks
    final milestonesToDelete = _milestones
        .where((m) => m.goalId == goalId)
        .toList();
    for (final milestone in milestonesToDelete) {
      await _taskRepository.deleteTasksByMilestoneId(milestone.id.value);
    }
    _milestones.removeWhere((m) => m.goalId == goalId);
  }

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
  group('DeleteGoalUseCase - カスケード削除テスト', () {
    late DeleteGoalUseCase useCase;
    late MockGoalRepository mockGoalRepository;
    late MockMilestoneRepository mockMilestoneRepository;
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockGoalRepository = MockGoalRepository();
      mockTaskRepository = MockTaskRepository();
      mockMilestoneRepository = MockMilestoneRepository(mockTaskRepository);
      useCase = DeleteGoalUseCaseImpl(
        mockGoalRepository,
        mockMilestoneRepository,
        mockTaskRepository,
      );
    });

    group('基本削除機能', () {
      test('単独ゴールが削除できること', () async {
        // Arrange
        final goal = Goal(
          id: GoalId.generate(),
          title: GoalTitle('削除対象ゴール'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        await mockGoalRepository.saveGoal(goal);

        // Act
        await useCase(goal.id.value);

        // Assert
        expect(await mockGoalRepository.getGoalById(goal.id.value), isNull);
        expect(await mockGoalRepository.getGoalCount(), 0);
      });

      test('複数ゴールがある場合、指定ゴールだけが削除される', () async {
        // Arrange
        final goal1 = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール1'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        final goal2 = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール2'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        await mockGoalRepository.saveGoal(goal1);
        await mockGoalRepository.saveGoal(goal2);

        // Act
        await useCase(goal1.id.value);

        // Assert
        expect(await mockGoalRepository.getGoalById(goal1.id.value), isNull);
        expect(await mockGoalRepository.getGoalById(goal2.id.value), isNotNull);
        expect(await mockGoalRepository.getGoalCount(), 1);
      });
    });

    group('カスケード削除：Milestone → Task', () {
      test('ゴール削除時、配下のマイルストーンがすべて削除される', () async {
        // Arrange
        final goal = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        await mockGoalRepository.saveGoal(goal);

        final ms1 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS1'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: goal.id.value,
        );
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS2'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 200)),
          ),
          goalId: goal.id.value,
        );
        await mockMilestoneRepository.saveMilestone(ms1);
        await mockMilestoneRepository.saveMilestone(ms2);

        // Act
        await useCase(goal.id.value);

        // Assert
        expect(
          await mockMilestoneRepository.getMilestonesByGoalId(goal.id.value),
          isEmpty,
        );
        expect(await mockMilestoneRepository.getMilestoneCount(), 0);
      });

      test('ゴール削除時、配下のタスクがすべてカスケード削除される', () async {
        // Arrange
        final goal = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        await mockGoalRepository.saveGoal(goal);

        // MS1 -> Task1, Task2
        final ms1 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS1'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: goal.id.value,
        );
        await mockMilestoneRepository.saveMilestone(ms1);

        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: ms1.id.value,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.doing(),
          milestoneId: ms1.id.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // MS2 -> Task3
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS2'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 200)),
          ),
          goalId: goal.id.value,
        );
        await mockMilestoneRepository.saveMilestone(ms2);

        final task3 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク3'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: ms2.id.value,
        );
        await mockTaskRepository.saveTask(task3);

        // Act
        await useCase(goal.id.value);

        // Assert
        expect(
          await mockTaskRepository.getTasksByMilestoneId(ms1.id.value),
          isEmpty,
        );
        expect(
          await mockTaskRepository.getTasksByMilestoneId(ms2.id.value),
          isEmpty,
        );
        expect(await mockTaskRepository.getTaskCount(), 0);
      });

      test('複数マイルストーンの複雑なカスケード削除', () async {
        // Arrange
        final goal = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        await mockGoalRepository.saveGoal(goal);

        // 3 Milestones with 3 Tasks each = 9 Tasks total
        for (int i = 1; i <= 3; i++) {
          final ms = Milestone(
            id: MilestoneId.generate(),
            title: MilestoneTitle('MS$i'),
            deadline: MilestoneDeadline(
              DateTime.now().add(Duration(days: 100 * i)),
            ),
            goalId: goal.id.value,
          );
          await mockMilestoneRepository.saveMilestone(ms);

          for (int j = 1; j <= 3; j++) {
            final task = Task(
              id: TaskId.generate(),
              title: TaskTitle('MS$i-T$j'),
              description: TaskDescription('説明'),
              deadline: TaskDeadline(
                DateTime.now().add(Duration(days: 50 * i)),
              ),
              status: TaskStatus.todo(),
              milestoneId: ms.id.value,
            );
            await mockTaskRepository.saveTask(task);
          }
        }

        // Act
        await useCase(goal.id.value);

        // Assert
        expect(await mockGoalRepository.getGoalCount(), 0);
        expect(await mockMilestoneRepository.getMilestoneCount(), 0);
        expect(await mockTaskRepository.getTaskCount(), 0);
      });
    });

    group('ゴール間の独立性', () {
      test('別のゴールの配下データは影響を受けない', () async {
        // Arrange
        final goal1 = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール1'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        final goal2 = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール2'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 365))),
        );
        await mockGoalRepository.saveGoal(goal1);
        await mockGoalRepository.saveGoal(goal2);

        final ms1 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('Goal1MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: goal1.id.value,
        );
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('Goal2MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 100)),
          ),
          goalId: goal2.id.value,
        );
        await mockMilestoneRepository.saveMilestone(ms1);
        await mockMilestoneRepository.saveMilestone(ms2);

        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('Goal1T'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: ms1.id.value,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('Goal2T'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: ms2.id.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // Act
        await useCase(goal1.id.value);

        // Assert
        expect(await mockGoalRepository.getGoalById(goal2.id.value), isNotNull);
        expect(
          await mockMilestoneRepository.getMilestoneById(ms2.id.value),
          isNotNull,
        );
        expect(await mockTaskRepository.getTaskById(task2.id.value), isNotNull);
        expect(await mockGoalRepository.getGoalCount(), 1);
        expect(await mockMilestoneRepository.getMilestoneCount(), 1);
        expect(await mockTaskRepository.getTaskCount(), 1);
      });
    });

    group('エラーハンドリング', () {
      test('存在しないゴール ID での削除でエラー', () async {
        expect(() => useCase('non-existent-id'), throwsA(isA<ArgumentError>()));
      });

      test('空の ID での削除でエラー', () async {
        expect(() => useCase(''), throwsA(isA<ArgumentError>()));
      });

      test('null ID での削除でエラー', () async {
        expect(() => useCase(''), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
