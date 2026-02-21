import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/delete_goal_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';

import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

class MockGoalRepository implements GoalRepository {
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
}

class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<List<Milestone>> getAllMilestones() async => _milestones;

  @override
  Future<Milestone?> getMilestoneById(String id) async => _milestones
      .firstWhere((m) => m.itemId.value == id, orElse: () => throw Exception());

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
  group('DeleteGoalUseCase', () {
    late DeleteGoalUseCase useCase;
    late MockGoalRepository goalRepository;
    late MockMilestoneRepository milestoneRepository;
    late MockTaskRepository taskRepository;

    setUp(() {
      goalRepository = MockGoalRepository();
      milestoneRepository = MockMilestoneRepository();
      taskRepository = MockTaskRepository();
      useCase = DeleteGoalUseCaseImpl(
        goalRepository,
        milestoneRepository,
        taskRepository,
      );
    });

    test('空のゴール ID でエラーが発生すること', () async {
      expect(() => useCase.call(''), throwsArgumentError);
    });

    test('存在しないゴール ID でエラーが発生すること', () async {
      expect(() => useCase.call('non-existent'), throwsArgumentError);
    });

    test('ゴールが削除されること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final goal = Goal(
        itemId: ItemId('goal-1'),
        title: ItemTitle('削除対象'),
        category: GoalCategory('カテゴリ'),
        description: ItemDescription('理由'),
        deadline: ItemDeadline(tomorrow),
      );

      await goalRepository.saveGoal(goal);
      expect(await goalRepository.getGoalCount(), 1);

      await useCase.call('goal-1');

      expect(await goalRepository.getGoalCount(), 0);
    });
  });
}
