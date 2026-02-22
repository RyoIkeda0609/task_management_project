import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/persistence/hive/hive_repository_base.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/application/use_cases/goal/create_goal_use_case.dart';
import 'package:app/application/use_cases/goal/get_all_goals_use_case.dart';
import 'package:app/application/use_cases/goal/delete_goal_use_case.dart';
import 'package:app/application/use_cases/milestone/create_milestone_use_case.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/application/use_cases/task/change_task_status_use_case.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';

import 'package:app/application/use_cases/task/get_all_tasks_today_use_case.dart';

// ===== Helper =====

Goal _createGoal(DateTime deadline) {
  return Goal(
    itemId: ItemId.generate(),
    title: ItemTitle('テスト'),
    category: GoalCategory('キャリア'),
    description: ItemDescription('説明'),
    deadline: ItemDeadline(deadline),
  );
}

/// すべてのメソッドで RepositoryException をスローする GoalRepository
class FailingGoalRepository implements GoalRepository {
  @override
  Future<List<Goal>> getAllGoals() async =>
      throw RepositoryException('DB read failed', Exception('I/O error'));

  @override
  Future<Goal?> getGoalById(String id) async =>
      throw RepositoryException('DB read failed');

  @override
  Future<void> saveGoal(Goal goal) async =>
      throw RepositoryException('DB write failed');

  @override
  Future<void> deleteGoal(String id) async =>
      throw RepositoryException('DB delete failed');

  @override
  Future<void> deleteAllGoals() async =>
      throw RepositoryException('DB clear failed');

  @override
  Future<int> getGoalCount() async =>
      throw RepositoryException('DB count failed');
}

/// すべてのメソッドで RepositoryException をスローする MilestoneRepository
class FailingMilestoneRepository implements MilestoneRepository {
  @override
  Future<List<Milestone>> getAllMilestones() async =>
      throw RepositoryException('DB read failed');

  @override
  Future<Milestone?> getMilestoneById(String id) async =>
      throw RepositoryException('DB read failed');

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      throw RepositoryException('DB read failed');

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      throw RepositoryException('DB write failed');

  @override
  Future<void> deleteMilestone(String id) async =>
      throw RepositoryException('DB delete failed');

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      throw RepositoryException('DB delete failed');

  @override
  Future<int> getMilestoneCount() async =>
      throw RepositoryException('DB count failed');
}

/// すべてのメソッドで RepositoryException をスローする TaskRepository
class FailingTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getAllTasks() async =>
      throw RepositoryException('DB read failed');

  @override
  Future<Task?> getTaskById(String id) async =>
      throw RepositoryException('DB read failed');

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      throw RepositoryException('DB read failed');

  @override
  Future<void> saveTask(Task task) async =>
      throw RepositoryException('DB write failed');

  @override
  Future<void> deleteTask(String id) async =>
      throw RepositoryException('DB delete failed');

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      throw RepositoryException('DB delete failed');

  @override
  Future<int> getTaskCount() async =>
      throw RepositoryException('DB count failed');
}

/// 正常に動作する最小限の GoalRepository
class WorkingGoalRepository implements GoalRepository {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> getAllGoals() async => _goals;

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async => _goals.add(goal);

  @override
  Future<void> deleteGoal(String id) async =>
      _goals.removeWhere((g) => g.itemId.value == id);

  @override
  Future<void> deleteAllGoals() async => _goals.clear();

  @override
  Future<int> getGoalCount() async => _goals.length;

  /// テスト用: ゴールを直接追加
  void addGoal(Goal goal) => _goals.add(goal);
}

/// 正常に動作する最小限の MilestoneRepository
class WorkingMilestoneRepository implements MilestoneRepository {
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
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      _milestones.where((m) => m.goalId.value == goalId).toList();

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.itemId.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId.value == goalId);

  @override
  Future<int> getMilestoneCount() async => _milestones.length;

  void addMilestone(Milestone milestone) => _milestones.add(milestone);
}

/// 正常に動作する最小限の TaskRepository
class WorkingTaskRepository implements TaskRepository {
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
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.where((t) => t.milestoneId.value == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.itemId.value == id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      _tasks.removeWhere((t) => t.milestoneId.value == milestoneId);

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

void main() {
  final tomorrow = DateTime.now().add(const Duration(days: 1));

  group('UseCase 例外伝搬テスト', () {
    group('CreateGoalUseCase', () {
      test('saveGoal() が RepositoryException をスローした場合、例外が伝搬する', () async {
        final useCase = CreateGoalUseCaseImpl(FailingGoalRepository());

        expect(
          () => useCase.call(
            title: 'テスト',
            category: 'キャリア',
            description: '説明',
            deadline: tomorrow,
          ),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('GetAllGoalsUseCase', () {
      test('getAllGoals() が RepositoryException をスローした場合、例外が伝搬する', () async {
        final useCase = GetAllGoalsUseCaseImpl(FailingGoalRepository());

        expect(() => useCase.call(), throwsA(isA<RepositoryException>()));
      });
    });

    group('DeleteGoalUseCase', () {
      test('getGoalById() が RepositoryException をスローした場合、例外が伝搬する', () async {
        final useCase = DeleteGoalUseCaseImpl(
          FailingGoalRepository(),
          WorkingMilestoneRepository(),
          WorkingTaskRepository(),
        );

        expect(
          () => useCase.call('goal-1'),
          throwsA(isA<RepositoryException>()),
        );
      });

      test(
        'getMilestonesByGoalId() が RepositoryException をスローした場合、例外が伝搬する',
        () async {
          // goalRepo は正常だが milestoneRepo が失敗するケース
          final goalRepo = WorkingGoalRepository();
          // ゴールを先に追加
          final goal = _createGoal(tomorrow);
          goalRepo.addGoal(goal);

          final useCase = DeleteGoalUseCaseImpl(
            goalRepo,
            FailingMilestoneRepository(),
            WorkingTaskRepository(),
          );

          expect(
            () => useCase.call(goal.itemId.value),
            throwsA(isA<RepositoryException>()),
          );
        },
      );
    });

    group('CreateMilestoneUseCase', () {
      test('getGoalById() が RepositoryException をスローした場合、例外が伝搬する', () async {
        final useCase = CreateMilestoneUseCaseImpl(
          WorkingMilestoneRepository(),
          FailingGoalRepository(),
        );

        expect(
          () => useCase.call(
            title: 'テスト',
            description: '説明',
            deadline: tomorrow,
            goalId: 'goal-1',
          ),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('saveMilestone() が RepositoryException をスローした場合、例外が伝搬する', () async {
        final goalRepo = WorkingGoalRepository();
        final goal = _createGoal(tomorrow);
        goalRepo.addGoal(goal);

        final useCase = CreateMilestoneUseCaseImpl(
          FailingMilestoneRepository(),
          goalRepo,
        );

        expect(
          () => useCase.call(
            title: 'MS1',
            description: '説明',
            deadline: tomorrow,
            goalId: goal.itemId.value,
          ),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('CreateTaskUseCase', () {
      test(
        'getMilestoneById() が RepositoryException をスローした場合、例外が伝搬する',
        () async {
          final useCase = CreateTaskUseCaseImpl(
            WorkingTaskRepository(),
            FailingMilestoneRepository(),
          );

          expect(
            () => useCase.call(
              title: 'テスト',
              description: '説明',
              deadline: tomorrow,
              milestoneId: 'ms-1',
            ),
            throwsA(isA<RepositoryException>()),
          );
        },
      );
    });

    group('ChangeTaskStatusUseCase', () {
      test('getTaskById() が RepositoryException をスローした場合、例外が伝搬する', () async {
        final useCase = ChangeTaskStatusUseCaseImpl(FailingTaskRepository());

        expect(
          () => useCase.call('task-1'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('GetAllTasksTodayUseCase', () {
      test('getAllTasks() が RepositoryException をスローした場合、例外が伝搬する', () async {
        final useCase = GetAllTasksTodayUseCaseImpl(FailingTaskRepository());

        expect(() => useCase.call(), throwsA(isA<RepositoryException>()));
      });
    });
  });

  group('RepositoryException 原因追跡テスト', () {
    test('スローされた RepositoryException の cause が保持されている', () async {
      final useCase = GetAllGoalsUseCaseImpl(FailingGoalRepository());

      try {
        await useCase.call();
        fail('例外がスローされるべき');
      } on RepositoryException catch (e) {
        expect(e.message, 'DB read failed');
        // FailingGoalRepository.getAllGoals の cause は Exception('I/O error')
        expect(e.cause, isA<Exception>());
      }
    });
  });
}
