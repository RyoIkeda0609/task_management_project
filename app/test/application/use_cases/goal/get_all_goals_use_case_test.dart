import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/get_all_goals_use_case.dart';
import 'package:app/domain/entities/goal.dart';

import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

import 'package:app/domain/repositories/goal_repository.dart';

class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> getAllGoals() async => _goals;

  @override
  Future<Goal?> getGoalById(String id) async => _goals.firstWhere(
    (g) => g.itemId.value == id,
    orElse: () => throw Exception(),
  );

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

void main() {
  group('GetAllGoalsUseCase', () {
    late GetAllGoalsUseCase useCase;
    late MockGoalRepository repository;

    setUp(() {
      repository = MockGoalRepository();
      useCase = GetAllGoalsUseCaseImpl(repository);
    });

    test('ゴールが存在しない場合は空のリストが返されること', () async {
      final goals = await useCase.call();
      expect(goals, isEmpty);
    });

    test('複数のゴールが返されること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      final goal1 = Goal(
        itemId: ItemId('goal-1'),
        title: ItemTitle('ゴール1'),
        category: GoalCategory('カテゴリ1'),
        description: ItemDescription('理由1'),
        deadline: ItemDeadline(tomorrow),
      );

      final goal2 = Goal(
        itemId: ItemId('goal-2'),
        title: ItemTitle('ゴール2'),
        category: GoalCategory('カテゴリ2'),
        description: ItemDescription('理由2'),
        deadline: ItemDeadline(tomorrow),
      );

      await repository.saveGoal(goal1);
      await repository.saveGoal(goal2);

      final goals = await useCase.call();

      expect(goals, hasLength(2));
      expect(goals.first.title.value, 'ゴール1');
      expect(goals.last.title.value, 'ゴール2');
    });
  });
}
