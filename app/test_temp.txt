import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/update_goal_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
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
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/goal_completion_service.dart';

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
  Future<void> saveGoal(Goal goal) async {
    _goals.removeWhere((g) => g.id.value == goal.id.value);
    _goals.add(goal);
  }

  @override
  Future<void> deleteGoal(String id) async =>
      _goals.removeWhere((g) => g.id.value == id);

  @override
  Future<void> deleteAllGoals() async => _goals.clear();

  @override
  Future<int> getGoalCount() async => _goals.length;
}

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
  Future<void> saveMilestone(Milestone milestone) async {
    _milestones.removeWhere((m) => m.id.value == milestone.id.value);
    _milestones.add(milestone);
  }

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
  group('UpdateGoalUseCase', () {
    late UpdateGoalUseCase useCase;
    late MockGoalRepository goalRepository;
    late MockMilestoneRepository milestoneRepository;
    late MockTaskRepository taskRepository;
    late GoalCompletionService goalCompletionService;

    setUp(() {
      goalRepository = MockGoalRepository();
      milestoneRepository = MockMilestoneRepository();
      taskRepository = MockTaskRepository();
      goalCompletionService = GoalCompletionService(
        milestoneRepository,
        taskRepository,
      );
      useCase = UpdateGoalUseCaseImpl(goalRepository, goalCompletionService);
    });

    test('存在しないゴール ID でエラーが発生すること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      expect(
        () => useCase.call(
          goalId: 'non-existent',
          title: 'タイトル',
          category: 'カテゴリ',
          reason: '理由',
          deadline: tomorrow,
        ),
        throwsArgumentError,
      );
    });

    test('ゴール ID が正しければゴールが更新されること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('元のタイトル'),
        category: GoalCategory('元のカテゴリ'),
        reason: GoalReason('元の理由'),
        deadline: GoalDeadline(tomorrow),
      );

      await goalRepository.saveGoal(goal);

      final nextDay = tomorrow.add(const Duration(days: 1));
      final updatedGoal = await useCase.call(
        goalId: 'goal-1',
        title: '新しいタイトル',
        category: '新しいカテゴリ',
        reason: '新しい理由',
        deadline: nextDay,
      );

      expect(updatedGoal.title.value, '新しいタイトル');
      expect(updatedGoal.category.value, '新しいカテゴリ');
      expect(updatedGoal.reason.value, '新しい理由');
    });

    test('完了（進捗100%）のゴールは編集できないこと', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('元のタイトル'),
        category: GoalCategory('元のカテゴリ'),
        reason: GoalReason('元の理由'),
        deadline: GoalDeadline(tomorrow),
      );

      await goalRepository.saveGoal(goal);

      // マイルストーンを作成し、すべてのタスクを完了させる
      final milestone = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('マイルストーン1'),
        deadline: MilestoneDeadline(tomorrow),
        goalId: 'goal-1',
      );
      await milestoneRepository.saveMilestone(milestone);

      // タスク1：Done
      final task1 = Task(
        id: TaskId('task-1'),
        title: TaskTitle('タスク1'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(tomorrow),
        status: TaskStatus.done(),
        milestoneId: 'milestone-1',
      );
      await taskRepository.saveTask(task1);

      // ゴール更新を試みる → エラー
      final nextDay = tomorrow.add(const Duration(days: 1));
      expect(
        () => useCase.call(
          goalId: 'goal-1',
          title: '新しいタイトル',
          category: 'カテゴリ',
          reason: '理由',
          deadline: nextDay,
        ),
        throwsArgumentError,
      );
    });
  });
}
