import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/delete_goal_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/infrastructure/repositories/goal_repository.dart';
import 'package:app/infrastructure/repositories/milestone_repository.dart';

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
  Future<Milestone?> getMilestoneById(String id) async => _milestones
      .firstWhere((m) => m.id.value == id, orElse: () => throw Exception());

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      _milestones.where((m) => m.id.value.startsWith(goalId)).toList();

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.id.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      _milestones.removeWhere((m) => m.id.value.startsWith(goalId));

  @override
  Future<int> getMilestoneCount() async => _milestones.length;
}

void main() {
  group('DeleteGoalUseCase', () {
    late DeleteGoalUseCase useCase;
    late MockGoalRepository goalRepository;
    late MockMilestoneRepository milestoneRepository;

    setUp(() {
      goalRepository = MockGoalRepository();
      milestoneRepository = MockMilestoneRepository();
      useCase = DeleteGoalUseCaseImpl(goalRepository, milestoneRepository);
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
        id: GoalId('goal-1'),
        title: GoalTitle('削除対象'),
        category: GoalCategory('カテゴリ'),
        reason: GoalReason('理由'),
        deadline: GoalDeadline(tomorrow),
      );

      await goalRepository.saveGoal(goal);
      expect(await goalRepository.getGoalCount(), 1);

      await useCase.call('goal-1');

      expect(await goalRepository.getGoalCount(), 0);
    });
  });
}
